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
  final int? nextChalanNumber;

  const AddChalanPage({super.key, required this.organization, this.chalan, this.nextChalanNumber});

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
    }else{
      _chalanNumberController.text = "${widget.nextChalanNumber}";
      print("widget.nextChalanNumber = ${widget.nextChalanNumber}");
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      final fileName =
          '${chalanId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageBytes = await _selectedImage!.readAsBytes();

      await supabase.storage
          .from(chalanImagesBucket)
          .uploadBinary(fileName, imageBytes);

      return supabase.storage.from(chalanImagesBucket).getPublicUrl(fileName);
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      final chalanId = const Uuid().v4();
      // 1. Get current chalan number from org
      // final orgResponse = await supabase
      //     .from(organizationsTable)
      //     .select('current_chalan_number')
      //     .eq('id', widget.organization.id)
      //     .maybeSingle();
      //
      // if (orgResponse == null || orgResponse['current_chalan_number'] == null) {
      //   throw Exception('Organization counter not found');
      // }
      //
      // final nextChalanNumber = orgResponse['current_chalan_number'] as int;

      // 2. Save new chalan
      await supabase.from(chalansTable).insert({
        'id': chalanId,
        'chalan_number': _chalanNumberController.text,
        'description': _descriptionController.text.trim(),
        'image_url': imageUrl,
        'date_time': DateTime.now().toIso8601String(),
        'organization_id': widget.organization.id,
        'created_by': user.id,
      });

      // 3. Increment chalan number in organization
      // await supabase
      //     .from(organizationsTable)
      //     .update({'current_chalan_number': nextChalanNumber + 1})
      //     .eq('id', widget.organization.id);
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updateData = {
        'chalan_number': _chalanNumberController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      if (_selectedImage != null) {
        final newImageUrl = await _uploadImage();
        await _deleteOldImage(widget.chalan!.imageUrl);
        updateData['image_url'] = newImageUrl!;
      }

      await supabase
          .from(chalansTable)
          .update(updateData)
          .eq('id', widget.chalan!.id);

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    // Show existing image (update mode)
    if (_isUpdateMode &&
        widget.chalan?.imageUrl != null &&
        widget.chalan!.imageUrl!.isNotEmpty) {
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
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.grey),
                      ),
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
                  Text(
                    'Change',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
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
        Icon(Icons.add_a_photo, size: 48, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          AppStrings.selectImage,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to add image',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
                keyboardType: TextInputType.number,
                label: AppStrings.chalanNo,
                // I want to make the text field read-only for every.
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: AppStrings.description,
                maxLines: 3,
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
                onPressed: _isUpdateMode ? _updateChalan : _saveChalan,
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}



// command of the build release apk is
// flutter build apk --release --split-per-abi
// here the --split-per-abi flag is used to generate separate APKs for each ABI (Application Binary Interface) which can reduce the size of the APK and improve performance on different devices. This is particularly useful for apps that include native code or large assets, as it allows the app to be optimized for each specific architecture (like arm64-v8a, armeabi-v7a, x86_64, etc.).