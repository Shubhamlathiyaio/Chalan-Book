import 'dart:io';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/core/models/chalan.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/organization.dart';
import '../../../main.dart';

class AddChalanPage extends StatefulWidget {
  final Organization organization;
  final Chalan? chalan;

  const AddChalanPage({super.key, required this.organization, this.chalan});

  @override
  State<AddChalanPage> createState() => _AddChalanPageState();
}

class _AddChalanPageState extends State<AddChalanPage> {
  final _chalanNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _chalanNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickImage(ImageSource source) async {
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
        context.showSnackBar('Error picking image: $error', isError: true);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(AppStrings.camera),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveChalan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final chalanId = const Uuid().v4();
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        final fileName =
            '${chalanId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageBytes = await _selectedImage!.readAsBytes();

        await supabase.storage
            .from(chalanImagesBucket)
            .uploadBinary(fileName, imageBytes);

        imageUrl = supabase.storage
            .from(chalanImagesBucket)
            .getPublicUrl(fileName);
      }

      // Save chalan to database
      await supabase.from(chalansTable).insert({
        'id': chalanId,
        'chalan_number': _chalanNumberController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': imageUrl,
        'date_time': DateTime.now().toIso8601String(),
        'organization_id': widget.organization.id,
        'created_by': user.id,
      });

      if (mounted) {
        context.showSnackBar('Chalan added successfully!');
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Error saving chalan: $error', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateChalan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl = widget.chalan!.imageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        final fileName =
            '${widget.chalan!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageBytes = await _selectedImage!.readAsBytes();

        await supabase.storage
            .from(chalanImagesBucket)
            .uploadBinary(fileName, imageBytes);

        imageUrl = supabase.storage
            .from(chalanImagesBucket)
            .getPublicUrl(fileName);
      }

      // Update chalan in DB
      await supabase
          .from(chalansTable)
          .update({
            'chalan_number': _chalanNumberController.text.trim(),
            'description': _descriptionController.text.trim(),
            'image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.chalan!.id);

      if (mounted) {
        context.showSnackBar('Chalan updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error updating chalan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.chalan != null;

    return Scaffold(
      appBar: AppBar(title: Text(isUpdate ? 'Update Chalan' : 'Add Chalan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ IMAGE SECTION
            if (isUpdate && widget.chalan!.imageUrl != null)
              GestureDetector(
                onTap: () => _showImageSourceDialog(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Image:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.chalan!.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // ✅ COMMON FIELDS
            TextFormField(
              initialValue: (isUpdate ? widget.chalan?.chalanNumber : 0)
                  .toString(),
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: isUpdate ? widget.chalan?.description : '',
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            const Spacer(),

            // ✅ BUTTON
            ElevatedButton.icon(
              onPressed: () {
                if (isUpdate) {
                  _updateChalan();
                } else {
                  _saveChalan();
                }
              },
              icon: Icon(isUpdate ? Icons.save : Icons.add),
              label: Text(isUpdate ? 'Update Chalan' : 'Add Chalan'),
            ),
          ],
        ),
      ),
    );
  }
}
