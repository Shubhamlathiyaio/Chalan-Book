import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/filter/filter_bloc.dart';
import '../../bloc/filter/filter_event.dart';
import '../../bloc/filter/filter_state.dart';
import '../../features/filter/filter_model.dart';
/// Widget for chalan filtering UI
class ChalanFilterWidget extends StatefulWidget {
  const ChalanFilterWidget({super.key});

  @override
  State<ChalanFilterWidget> createState() => _ChalanFilterWidgetState();
}

class _ChalanFilterWidgetState extends State<ChalanFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChalanFilterBloc, ChalanFilterState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Bar
              _buildSearchBar(state),

              SizedBox(height: 12.h),

              // Filter Chips Row
              _buildFilterChips(state),

              // Expanded Filter Options
              if (_isFilterExpanded) ...[
                SizedBox(height: 16.h),
                _buildExpandedFilters(state),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Build search bar
  Widget _buildSearchBar(ChalanFilterState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search chalan number or date (e.g. 1002, 2025-07-15)',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              context.read<ChalanFilterBloc>().add(
                UpdateSearchQueryEvent(''),
              );
            },
            icon: Icon(Icons.clear, color: Colors.grey[600]),
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        onChanged: (query) {
          context.read<ChalanFilterBloc>().add(
            UpdateSearchQueryEvent(query),
          );
        },
      ),
    );
  }

  /// Build filter chips row
  Widget _buildFilterChips(ChalanFilterState state) {
    return Row(
      children: [
        // Current filter display
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  state.filter.displayText,
                  isActive: true,
                  onTap: () => _showFilterBottomSheet(context, state),
                ),

                SizedBox(width: 8.w),

                // Chalan number range chip
                if (state.filter.chalanNumberRange != ChalanNumberRange.all)
                  _buildFilterChip(
                    '🔢 ${state.filter.chalanNumberRange.name}',
                    isActive: true,
                    onTap: () => _showChalanNumberRangeDialog(context),
                  ),

                SizedBox(width: 8.w),

                // Results count
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${state.filteredChalans.length} results',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Clear filters button
        if (state.filter.isActive)
          IconButton(
            onPressed: () {
              _searchController.clear();
              context.read<ChalanFilterBloc>().add(ClearAllFiltersEvent());
            },
            icon: Icon(Icons.clear_all, color: Colors.red[600]),
            tooltip: 'Clear all filters',
          ),
      ],
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(
      String label, {
        required bool isActive,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              size: 16.w,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  /// Build expanded filters
  Widget _buildExpandedFilters(ChalanFilterState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12.h),

          // Filter type buttons
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildFilterButton('📆 This Year', FilterType.thisYear, state),
              _buildFilterButton('🔄 All Years', FilterType.allYears, state),
              _buildFilterButton('🗓️ By Month', FilterType.byMonth, state),
              _buildFilterButton('📅 By Date', FilterType.byDate, state),
              _buildFilterButton('👤 Created By Me', FilterType.createdByMe, state),
            ],
          ),
        ],
      ),
    );
  }

  /// Build filter button
  Widget _buildFilterButton(
      String label,
      FilterType filterType,
      ChalanFilterState state,
      ) {
    final isActive = state.filter.filterType == filterType;

    return GestureDetector(
      onTap: () {
        switch (filterType) {
          case FilterType.byMonth:
            _showMonthPicker(context);
            break;
          case FilterType.byDate:
            _showDatePicker(context);
            break;
          default:
            context.read<ChalanFilterBloc>().add(
              ChangeFilterTypeEvent(filterType),
            );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context, ChalanFilterState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _FilterBottomSheet(currentFilter: state.filter),
    );
  }

  /// Show month picker
  void _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => _MonthPickerDialog(
        initialMonth: now.month,
        initialYear: now.year,
      ),
    );

    if (result != null) {
      context.read<ChalanFilterBloc>().add(
        ChangeFilterTypeEvent(
          FilterType.byMonth,
          month: result['month'],
          year: result['year'],
        ),
      );
    }
  }

  /// Show date picker
  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      context.read<ChalanFilterBloc>().add(
        ChangeFilterTypeEvent(FilterType.byDate, date: date),
      );
    }
  }

  /// Show chalan number range dialog
  void _showChalanNumberRangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ChalanNumberRangeDialog(),
    );
  }
}

/// Filter bottom sheet widget
class _FilterBottomSheet extends StatelessWidget {
  final ChalanFilter currentFilter;

  const _FilterBottomSheet({required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Filter options
          _buildFilterOption(
            context,
            '📆 This Year',
            'Show chalans from current year',
            FilterType.thisYear,
          ),
          _buildFilterOption(
            context,
            '🔄 All Years',
            'Show chalans from all years',
            FilterType.allYears,
          ),
          _buildFilterOption(
            context,
            '👤 Created By Me',
            'Show only chalans I created',
            FilterType.createdByMe,
          ),

          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ChalanFilterBloc>().add(ClearAllFiltersEvent());
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
      BuildContext context,
      String title,
      String subtitle,
      FilterType filterType,
      ) {
    final isSelected = currentFilter.filterType == filterType;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        context.read<ChalanFilterBloc>().add(
          ChangeFilterTypeEvent(filterType),
        );
        Navigator.pop(context);
      },
    );
  }
}

/// Month picker dialog
class _MonthPickerDialog extends StatefulWidget {
  final int initialMonth;
  final int initialYear;

  const _MonthPickerDialog({
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
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
      title: const Text('Select Month'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year selector
          Row(
            children: [
              const Text('Year: '),
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(10, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (year) {
                  if (year != null) {
                    setState(() => selectedYear = year);
                  }
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Month selector
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == selectedMonth;

              return GestureDetector(
                onTap: () => setState(() => selectedMonth = month),
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      _getMonthName(month),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'month': selectedMonth,
            'year': selectedYear,
          }),
          child: const Text('Select'),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

/// Chalan number range dialog
class _ChalanNumberRangeDialog extends StatefulWidget {
  @override
  State<_ChalanNumberRangeDialog> createState() => _ChalanNumberRangeDialogState();
}

class _ChalanNumberRangeDialogState extends State<_ChalanNumberRangeDialog> {
  ChalanNumberRange selectedRange = ChalanNumberRange.all;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chalan Number Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRangeOption(ChalanNumberRange.all, 'All Numbers'),
          _buildRangeOption(ChalanNumberRange.below20, 'Below 20'),
          _buildRangeOption(ChalanNumberRange.between20And80, 'Between 20-80'),
          _buildRangeOption(ChalanNumberRange.above80, 'Above 80'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<ChalanFilterBloc>().add(
              SetChalanNumberRangeEvent(selectedRange),
            );
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildRangeOption(ChalanNumberRange range, String title) {
    return RadioListTile<ChalanNumberRange>(
      title: Text(title),
      value: range,
      groupValue: selectedRange,
      onChanged: (value) {
        if (value != null) {
          setState(() => selectedRange = value);
        }
      },
    );
  }
}
