import 'package:chalan_book_app/core/configs/app_typography.dart';
import 'package:chalan_book_app/core/configs/edge.dart';
import 'package:chalan_book_app/core/configs/gap.dart';
import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/core/models/chalan.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/features/chalan/bloc/chalan_bloc.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/services/mega_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddChalanPage extends StatefulWidget {
  final Organization organization;
  final List<Chalan>? chalans;
  final Chalan? chalan;

  const AddChalanPage({
    super.key,
    required this.organization,
    this.chalans,
    this.chalan,
  });

  @override
  State<AddChalanPage> createState() => _AddChalanPageState();
}

class _AddChalanPageState extends State<AddChalanPage> {
  late final bool isUpdateMode;
  final _formKey = GlobalKey<FormState>();
  late final _chalanNumberController = TextEditingController();
  late final _descriptionController = TextEditingController();
  late final FocusNode _chalanFocusNode;
  List<int> _missingNumbers = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    isUpdateMode = widget.chalan != null;
    _chalanFocusNode = FocusNode();

    final chalanState = context.read<ChalanBloc>().state;
    List<Chalan> existingChalans = chalanState is ChalanLoaded
        ? chalanState.chalans
        : [];

    // Debug Info
    print('Chalans length: ${widget.chalans?.length ?? 0}');
    print('Existing Chalans length: ${existingChalans.length}');
    print(
      'Chalans length equals Existing Chalans length: ${widget.chalans?.length == existingChalans.length}',
    );

    _missingNumbers = _calculateMissingNumbers(existingChalans);

    if (isUpdateMode) {
      _chalanNumberController.text = widget.chalan!.chalanNumber;
      _descriptionController.text = widget.chalan!.description ?? '';
      _selectedDate = widget.chalan!.dateTime;
    } else {
      _missingNumbers = _calculateMissingNumbers(widget.chalans ?? []);
      _chalanNumberController.text = _missingNumbers.length == 1
          ? "${_missingNumbers.first}"
          : "";
    }
  }

  List<int> _calculateMissingNumbers(List<Chalan> chalans) {
    final numbers = chalans
        .map((c) => int.tryParse(c.chalanNumber))
        .whereType<int>()
        .toSet();
    if (numbers.isEmpty) return [1];
    final max = numbers.reduce((a, b) => a > b ? a : b);

    final missing = <int>[];
    for (int i = 1; i <= max + 1; i++) {
      if (!numbers.contains(i)) missing.add(i);
    }
    return missing;
  }

  @override
  void dispose() {
    _chalanNumberController.dispose();
    _descriptionController.dispose();
    _chalanFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isUpdateMode
            ? const Text('Update Chalan')
            : const Text('Add New Chalan'),
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: BlocBuilder<ChalanBloc, ChalanState>(
        builder: (_, state) {
          return SingleChildScrollView(
            padding: edge.all16,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // gap.h8 and date button can be re-enabled if needed
                  gap.h8,
                  _buildChalanNumberField(state),
                  gap.h16,
                  _buildDescriptionField(),
                  gap.h16,
                  _buildImageSection(),
                  gap.h32,
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateButton() => BlocBuilder<ChalanBloc, ChalanState>(
    builder: (_, state) {
      return Align(
        alignment: Alignment.centerRight,
        child: Card(
          child: Padding(
            padding: edge.all8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('dd-MM-yyyy').format(
                    state is ChalanLoaded ? state.selectedDate : DateTime.now(),
                  ),
                  style: poppins.fs14,
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _selectDate,
                  child: const Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildChalanNumberField(ChalanState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chalan Number',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        gap.h8,
        TextFormField(
          controller: _chalanNumberController,
          focusNode: _chalanFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter chalan number',
            prefixIcon: const Icon(Icons.numbers),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please enter chalan number';
            final number = int.tryParse(value);
            if (number == null || number <= 0)
              return 'Please enter a valid number';
            return null;
          },
        ),
        if (!isUpdateMode && _missingNumbers.length > 1) ...[
          gap.h8,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _missingNumbers
                  .map(
                    (number) => GestureDetector(
                      onTap: () =>
                          _chalanNumberController.text = number.toString(),
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: edge.h12.v6,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: context.colors.outline,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          number.toString(),
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Description (Optional)',
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      gap.h8,
      TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter description...',
          prefixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ],
  );

  Widget _buildImageSection() => BlocBuilder<ChalanBloc, ChalanState>(
    builder: (_, state) {
      // Get image info regardless of state
      final selectedImage = (state is ChalanLoaded)
          ? state.selectedImage
          : null;
      final imageUrl = widget.chalan?.imageUrl;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chalan Image (Optional)',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          gap.h8,

          // Show image if available
          if (selectedImage != null || imageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    height: 200.h,
                    width: double.infinity,
                    child: selectedImage != null
                        ? Image.file(selectedImage, fit: BoxFit.cover)
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 200.h,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200.h,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 48.sp),
                                      Text('Failed to load image'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: _iconActionButton(
                    Icons.close,
                    () => context.read<ChalanBloc>().add(RemoveImage()),
                  ),
                ),
              ],
            )
          // Always show gallery/camera buttons when no image
          else
            Row(
              children: [
                _beautifulPickButton(
                  Icons.photo_library,
                  'Gallery',
                  () => context.read<ChalanBloc>().add(PickImageFromGallery()),
                ),
                gap.w8,
                _beautifulPickButton(
                  Icons.camera_alt,
                  'Camera',
                  () => context.read<ChalanBloc>().add(PickImageFromCamera()),
                ),
              ],
            ),
        ],
      );
    },
  );

  Widget _beautifulPickButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28.sp, color: context.colors.onSurface),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _iconActionButton(IconData icon, VoidCallback onPressed) =>
      CircleAvatar(
        backgroundColor: Colors.black54,
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      );

  Widget _buildSubmitButton() => BlocBuilder<ChalanBloc, ChalanState>(
    builder: (_, state) {
      final isLoading = state is ChalanLoading;
      return FilledButton(
        onPressed: isLoading ? null : () => _submitChalan(),
        style: FilledButton.styleFrom(
          padding: edge.v16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.chalan != null ? 'Update Chalan' : 'Save Chalan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );
    },
  );

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submitChalan() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      print('🟢 Starting chalan submission...');
      print('🟢 User ID: ${supabase.auth.currentUser?.id}');
      print('🟢 Organization ID: ${widget.organization.id}');

      String? imageUrl;
      final state = context.read<ChalanBloc>().state;

      // Upload image to Mega if selected
      if (state is ChalanLoaded && state.selectedImage != null) {
        print('🔄 Uploading image to Mega...');
        imageUrl = await MegaImageService.uploadImage(
          imageFile: state.selectedImage!,
        );

        if (imageUrl == null) {
          throw Exception('Failed to upload image to Mega');
        }
        print('✅ Image uploaded: $imageUrl');
      }

      final chalan = Chalan(
        id: widget.chalan?.id ?? const Uuid().v4(),
        organizationId: widget.organization.id,
        createdBy:
            widget.chalan?.createdBy ?? supabase.auth.currentUser?.id ?? "",
        chalanNumber: _chalanNumberController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: imageUrl ?? widget.chalan?.imageUrl, // ✅ Use Mega URL
        dateTime: _selectedDate,
      );

      print('🟢 Chalan object created: ${chalan.toJson()}');

      if (!mounted) return;

      if (isUpdateMode) {
        context.read<ChalanBloc>().add(UpdateChalanEvent(chalan));
      } else {
        context.read<ChalanBloc>().add(AddChalanEvent(chalan));
      }

      print('🟢 Bloc event dispatched');
      Navigator.pop(context);
    } catch (e) {
      print('🔴 Submit error: $e');
      context.showSnackbar('Error submitting chalan: $e', isError: true);
    }
  }
}
