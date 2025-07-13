import 'dart:io';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/organization.dart';
import '../../../core/models/chalan.dart';
import '../../../main.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';

class AddChalanPage extends StatefulWidget {
  final Organization organization;
  final Chalan? chalan; // If provided, this is an update operation

  const AddChalanPage({
    super.key,
    required this.organization,
    this.chalan,
  });

  @override
  State<AddChalanPage> createState() => _AddChalanPageState();
}

class _AddChalanPageState extends State<AddChalanPage> {
  final _formKey = GlobalKey<FormState>();
  final _chalanNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool get _isUpdateMode => widget.chalan != null;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (_isUpdateMode && widget.chalan != null) {
      _chalanNumberController.text = widget.chalan!.chalanNumber;
      _descriptionController.text = widget.chalan!.description ?? '';
    }
  }

  @override
  void dispose() {
    _chalanNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (error) {
      if (mounted) {
        _showSnackBar('Error picking image: $error', isError: true);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.camera_alt,
                      label: AppStrings.camera,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.photo_library,
                      label: AppStrings.gallery,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final chalanId = _isUpdateMode ? widget.chalan!.id : const Uuid().v4();
      final fileName = '${chalanId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageBytes = await _selectedImage!.readAsBytes();

      await supabase.storage
          .from(chalanImagesBucket)
          .uploadBinary(fileName, imageBytes);

      return supabase.storage
          .from(chalanImagesBucket)
          .getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _deleteOldImage(String? oldImageUrl) async {
    if (oldImageUrl == null || oldImageUrl.isEmpty) return;

    try {
      final uri = Uri.parse(oldImageUrl);
      final fileName = uri.pathSegments.last;
      await supabase.storage.from(chalanImagesBucket).remove([fileName]);
    } catch (e) {
      // Log error but don't throw - old image deletion failure shouldn't stop the update
      debugPrint('Failed to delete old image: $e');
    }
  }

 Future<void> _saveChalan() async {
  print('0');
  if (!_formKey.currentState!.validate()) return;
  print('1');

  setState(() => _isLoading = true);

  try {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    print('2');

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage();
    }

    print('3');

    final chalanId = const Uuid().v4();
    await supabase.from(chalansTable).insert({
      'id': chalanId,
      'chalan_number': _chalanNumberController.text.trim(),
      'description': _descriptionController.text.trim(),
      'image_url': imageUrl,
      'date_time': DateTime.now().toIso8601String(),
      'organization_id': widget.organization.id,
      'created_by': user.id,
    });

    print('4');
    if (mounted) {
      _showSnackBar('Chalan added successfully!');
      Navigator.pop(context, true);
    }
  } catch (error) {
    if (mounted) {
      _showSnackBar('Error saving chalan: $error', isError: true);
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


Future<void> _updateChalan() async {
  print('5');
  if (!_formKey.currentState!.validate()) return;
  print('6');

  setState(() => _isLoading = true);

  try {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    print('7');

    final updateData = {
      'chalan_number': _chalanNumberController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    if (_selectedImage != null) {
      print('8');
      final newImageUrl = await _uploadImage();
      await _deleteOldImage(widget.chalan!.imageUrl);
      updateData['image_url'] = newImageUrl!;
    }

    print('9');

    await supabase
        .from(chalansTable)
        .update(updateData)
        .eq('id', widget.chalan!.id);

    print('10');

    if (mounted) {
      _showSnackBar('Chalan updated successfully!');
      Navigator.pop(context, true);
    }
  } catch (error) {
    if (mounted) {
      _showSnackBar('Error updating chalan: $error', isError: true);
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}



  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!_isUpdateMode || _selectedImage != null || widget.chalan?.imageUrl == null)
              const Text(
                ' (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _buildImageContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    // Show selected image (new or replacement)
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Show existing image (update mode)
    if (_isUpdateMode && widget.chalan?.imageUrl != null && widget.chalan!.imageUrl!.isNotEmpty) {

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.chalan!.imageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show placeholder (no image)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 48,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.selectImage,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to add image',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdateMode ? 'Update Chalan' : AppStrings.addChalan),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Form Fields
              CustomTextField(
                controller: _chalanNumberController,
                label: AppStrings.chalanNumber,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter chalan number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descriptionController,
                label: AppStrings.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Organization Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organization',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              widget.organization.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              LoadingButton(
                onPressed: _isUpdateMode ? _updateChalan :_saveChalan,
                isLoading: _isLoading,
                text: _isUpdateMode ? 'Update Chalan' : AppStrings.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}