import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_bloc.dart';
import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_event.dart';
import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_state.dart';
import 'package:chalan_book_app/core/configs/app_typography.dart';
import 'package:chalan_book_app/features/filter/advanced_filter_model.dart';
import 'package:chalan_book_app/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Comprehensive filter bottom sheet
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final TextEditingController _fromChalanController = TextEditingController();
  final TextEditingController _toChalanController = TextEditingController();
  
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedMonth;
  int? _selectedYear;
  CreatedByFilter _selectedCreatedBy = CreatedByFilter.all;

  @override
  void initState() {
    super.initState();
    _initializeFromCurrentFilter();
  }

  @override
  void dispose() {
    _fromChalanController.dispose();
    _toChalanController.dispose();
    super.dispose();
  }

  void _initializeFromCurrentFilter() {
    final filter = context.read<AdvancedChalanFilterBloc>().state.filter;
    
    _fromDate = filter.fromDate;
    _toDate = filter.toDate;
    _selectedMonth = filter.selectedMonth;
    _selectedYear = filter.selectedYear;
    _selectedCreatedBy = filter.createdByFilter;
    
    if (filter.fromChalanNumber != null) {
      _fromChalanController.text = filter.fromChalanNumber.toString();
    }
    if (filter.toChalanNumber != null) {
      _toChalanController.text = filter.toChalanNumber.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvancedChalanFilterBloc, AdvancedChalanFilterState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: context.colors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              _buildHeader(context),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Filter Section
                      _buildDateFilterSection(context),
                      
                      SizedBox(height: 24.h),
                      
                      // Chalan Number Range Section
                      _buildChalanNumberRangeSection(context),
                      
                      SizedBox(height: 24.h),
                      
                      // Created By Section
                      _buildCreatedBySection(context),
                      
                      SizedBox(height: 24.h),
                      
                      // Month Filter Section
                      _buildMonthFilterSection(context),
                      
                      SizedBox(height: 32.h),
                      
                      // Apply Button
                      _buildApplyButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build header
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filter Chalans',
            style: poppins.w700.fs18.textColor(context.colors.onSurface),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              context.read<AdvancedChalanFilterBloc>().add(ClearAllFiltersEvent());
              Navigator.pop(context);
            },
            child: Text(
              'Clear All',
              style: poppins.w500.fs14.textColor(AppColors.xff002568),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: context.colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build date filter section
  Widget _buildDateFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📅 Date Filter',
          style: poppins.w600.fs16.textColor(context.colors.onSurface),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                context,
                'From',
                _fromDate,
                (date) => setState(() => _fromDate = date),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDatePicker(
                context,
                'To',
                _toDate,
                (date) => setState(() => _toDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build date picker
  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onDateSelected(date);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: context.colors.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: poppins.w500.fs12.textColor(
                context.colors.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'Select date',
              style: poppins.w400.fs14.textColor(
                selectedDate != null
                    ? context.colors.onSurface
                    : context.colors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build chalan number range section
  Widget _buildChalanNumberRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔢 Chalan Number Range',
          style: poppins.w600.fs16.textColor(context.colors.onSurface),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(context, 'From', _fromChalanController),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildNumberField(context, 'To', _toChalanController),
            ),
          ],
        ),
      ],
    );
  }

  /// Build number field
  Widget _buildNumberField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: poppins.w500.fs12.textColor(
            context.colors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: poppins.w400.fs14.textColor(context.colors.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter number',
            hintStyle: poppins.w400.fs14.textColor(
              context.colors.onSurface.withOpacity(0.5),
            ),
            filled: true,
            fillColor: context.colors.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: context.colors.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: context.colors.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: context.colors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  /// Build created by section
  Widget _buildCreatedBySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👤 Created By',
          style: poppins.w600.fs16.textColor(context.colors.onSurface),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: CreatedByFilter.values.map((filter) {
            final isSelected = _selectedCreatedBy == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedCreatedBy = filter),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withOpacity(0.1)
                      : context.colors.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${filter.emoji} ${filter.displayName}',
                  style: poppins.w500.fs12.textColor(
                    isSelected
                        ? context.colors.primary
                        : context.colors.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build month filter section
  Widget _buildMonthFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📅 Month Filter',
          style: poppins.w600.fs16.textColor(context.colors.onSurface),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => _showMonthYearPicker(context),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: context.colors.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: context.colors.primary,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  _selectedMonth != null && _selectedYear != null
                      ? '${_getMonthName(_selectedMonth!)} $_selectedYear'
                      : 'Select month and year',
                  style: poppins.w400.fs14.textColor(
                    _selectedMonth != null
                        ? context.colors.onSurface
                        : context.colors.onSurface.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.colors.onSurface.withOpacity(0.5),
                  size: 16.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build apply button
  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _applyFilters(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.xff002568,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Apply Filters',
          style: poppins.w600.fs16.textColor(Colors.white),
        ),
      ),
    );
  }

  /// Show month year picker
  void _showMonthYearPicker(BuildContext context) async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => _MonthYearPickerDialog(
        initialMonth: _selectedMonth ?? DateTime.now().month,
        initialYear: _selectedYear ?? DateTime.now().year,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result['month'];
        _selectedYear = result['year'];
      });
    }
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Apply filters
  void _applyFilters(BuildContext context) {
    final bloc = context.read<AdvancedChalanFilterBloc>();

    // Apply date range filter
    if (_fromDate != null || _toDate != null) {
      bloc.add(SetDateRangeFilterEvent(
        fromDate: _fromDate,
        toDate: _toDate,
      ));
    }

    // Apply chalan number range filter
    final fromNumber = int.tryParse(_fromChalanController.text);
    final toNumber = int.tryParse(_toChalanController.text);
    if (fromNumber != null || toNumber != null) {
      bloc.add(SetChalanNumberRangeFilterEvent(
        fromNumber: fromNumber,
        toNumber: toNumber,
      ));
    }

    // Apply created by filter
    bloc.add(SetCreatedByFilterEvent(_selectedCreatedBy));

    // Apply month filter
    if (_selectedMonth != null) {
      bloc.add(SetMonthFilterEvent(
        month: _selectedMonth,
        year: _selectedYear,
      ));
    }

    Navigator.pop(context);
  }
}

/// Month Year Picker Dialog
class _MonthYearPickerDialog extends StatefulWidget {
  final int initialMonth;
  final int initialYear;

  const _MonthYearPickerDialog({
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select Month & Year',
        style: poppins.w600.fs16.textColor(context.colors.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year selector
          DropdownButtonFormField<int>(
            value: selectedYear,
            decoration: InputDecoration(
              labelText: 'Year',
              labelStyle: poppins.w500.fs14.textColor(context.colors.onSurface),
            ),
            items: List.generate(10, (index) {
              final year = DateTime.now().year - index;
              return DropdownMenuItem(
                value: year,
                child: Text(
                  year.toString(),
                  style: poppins.w400.fs14.textColor(context.colors.onSurface),
                ),
              );
            }),
            onChanged: (year) => setState(() => selectedYear = year!),
          ),

          SizedBox(height: 16.h),

          // Month selector
          DropdownButtonFormField<int>(
            value: selectedMonth,
            decoration: InputDecoration(
              labelText: 'Month',
              labelStyle: poppins.w500.fs14.textColor(context.colors.onSurface),
            ),
            items: List.generate(12, (index) {
              final month = index + 1;
              return DropdownMenuItem(
                value: month,
                child: Text(
                  _getMonthName(month),
                  style: poppins.w400.fs14.textColor(context.colors.onSurface),
                ),
              );
            }),
            onChanged: (month) => setState(() => selectedMonth = month!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: poppins.w500.fs14.textColor(context.colors.onSurface.withOpacity(0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'month': selectedMonth,
            'year': selectedYear,
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.xff002568,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Select',
            style: poppins.w600.fs14.white,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
