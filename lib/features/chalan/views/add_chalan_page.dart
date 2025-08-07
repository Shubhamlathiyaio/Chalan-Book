import 'dart:io';

import 'package:chalan_book_app/core/configs/edge.dart';
import 'package:chalan_book_app/core/configs/gap.dart';
import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/core/extensions/typography_extension.dart';
import 'package:chalan_book_app/core/models/chalan.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/features/chalan/bloc/chalan_bloc.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/services/supa.dart';
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
  late final FocusNode _chalanFocusNode;
  List<int> _missingNumbers = [];
  final _descriptionController = TextEditingController();
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
    print('Chalans length: ${widget.chalans?.length ?? 0}');
    print('Existing Chalans length: ${existingChalans.length}');
    print('Chalans length equals Existing Chalans length: ${widget.chalans?.length == existingChalans.length}');

    _missingNumbers = _calculateMissingNumbers(existingChalans);

    if (widget.chalan != null) {
      _chalanNumberController.text = widget.chalan!.chalanNumber;

      _descriptionController.text = widget.chalan!.description ?? '';
      _selectedDate = widget.chalan!.dateTime;
    } else {
      _missingNumbers = _calculateMissingNumbers(widget.chalans ?? []);
      _chalanNumberController.text = _missingNumbers.length == 1
          ? "${_missingNumbers.first}"
          : "";
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<ChalanBloc>().state;
      if (state is ChalanLoaded) {
        context.read<ChalanBloc>().add(LoadMissingChalanNumbers(state.chalans));
      }
    });
  }

  List<int> _calculateMissingNumbers(List<Chalan> chalans) {
    final numbers = chalans
        .map((c) => int.tryParse(c.chalanNumber))
        .whereType<int>()
        .toSet();
    if (numbers.isEmpty) return [1];
    final max = numbers.reduce((a, b) => a > b ? a : b);
    final missing = <int>[];
    // for (int i = max + 1; i >= 1; i--) { // ascending order
    for (int i = 1; i <= max + 1; i++) { // descending order
      if (!numbers.contains(i)) missing.add(i);
    }
    return missing;
  }

  @override
  void dispose() {
    _chalanNumberController.dispose();
    _descriptionController.dispose();
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
        builder: (context, state) {
          return SingleChildScrollView(
            padding: edge.all16,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: GestureDetector(
                  //     onTap: () => _selectDate,
                  //     child: Card(
                  //       child: Padding(
                  //         padding: edge.all4,
                  //         child: Icon(Icons.calendar_today),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // gap.h8,
                  // _buildDateButton(),
                  gap.h8,

                  _buildChalanNumberField(state),
                  gap.h16,
                  _buildDescriptionField(),

                  gap.h16,
                  _buildImageSection(context),
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

  Widget _buildDateButton() {
    return BlocBuilder<ChalanBloc, ChalanState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.centerRight,
          child: Card(
            child: Padding(
              padding: edge.all8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<ChalanBloc, ChalanState>(
                    builder: (context, state) {
                      if (state is ChalanLoaded) {
                        return Text(
                          DateFormat('dd-MM-yyyy').format(state.selectedDate),
                          style: poppins.fs14,
                        );
                      } else {
                        return Text(
                          DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        );
                      }
                    },
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _selectDate(),
                    child: Icon(Icons.calendar_today),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChalanNumberField(ChalanState state) {
    final isEditMode = widget.chalan != null;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _chalanNumberController,
              focusNode: _chalanFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter chalan number',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter chalan number';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (value) {
                if (state is ChalanLoaded && state.selectedNumber != null) {
                  context.read<ChalanBloc>().add(ClearSelectedNumber());
                }
              },
            ),

            // Show missing numbers ONLY if not in edit mode and list has more than 1 item
            if (!isEditMode && _missingNumbers.length > 1) ...[
              gap.h8,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _missingNumbers.map((number) {
                    return GestureDetector(
                      onTap: () {
                        _chalanNumberController.text = number.toString();
                      },
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
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
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
  }

  Widget _buildImageSection(BuildContext context) {
    return BlocBuilder<ChalanBloc, ChalanState>(
      builder: (context, state) {
        if (state is! ChalanLoaded) return SizedBox();

        final File? selectedImage = state.selectedImage;
        final String? imageUrl = widget.chalan?.imageUrl;

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
            if (selectedImage != null || imageUrl != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: selectedImage != null
                        ? Image.file(
                            selectedImage,
                            height: 200.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl!,
                            height: 200.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: _iconActionButton(
                      icon: Icons.close,
                      onPressed: () =>
                          context.read<ChalanBloc>().add(RemoveImage()),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  _beautifulPickButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () =>
                        context.read<ChalanBloc>().add(PickImageFromGallery()),
                  ),
                  gap.w8,
                  _beautifulPickButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () =>
                        context.read<ChalanBloc>().add(PickImageFromCamera()),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _beautifulPickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
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
  }

  Widget _iconActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      backgroundColor: Colors.black54,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ChalanBloc, ChalanState>(
      builder: (context, state) {
        final isLoading = state is ChalanLoading;
        return FilledButton(
          onPressed: isLoading ? null : _submitChalan,
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
  }

  Future<void> _selectDate() async {
    print("From _selectDate");
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _submitChalan() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? imageUrl;
      final state = context.read<ChalanBloc>().state;

      if (state is ChalanLoaded && state.selectedImage != null) {
        imageUrl = await Supa().setImageAndGetUrl(
          imageFile: state.selectedImage!,
        );
      }

      final chalan = Chalan(
        id: widget.chalan?.id ?? const Uuid().v4(), // keep same id in edit mode
        organizationId: widget.organization.id,
        createdBy: widget.chalan?.createdBy ?? supabase.auth.currentUser!.id,
        chalanNumber: _chalanNumberController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: imageUrl ?? widget.chalan?.imageUrl,
        dateTime: _selectedDate,
      );

      if (!mounted) return;

      if (widget.chalan != null) {
        context.read<ChalanBloc>().add(UpdateChalanEvent(chalan));
      } else {
        context.read<ChalanBloc>().add(AddChalanEvent(chalan));
      }

      Navigator.pop(context);
    } catch (e) {
      context.showSnackbar('Error submitting chalan: $e', isError: true);
    }
  }
}
