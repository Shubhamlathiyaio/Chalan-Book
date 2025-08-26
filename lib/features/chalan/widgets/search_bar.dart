import 'package:chalan_book_app/core/configs/gap.dart';
import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/core/localization/app_localizations.dart';
import 'package:chalan_book_app/features/chalan/bloc/filter_bloc.dart';
import 'package:chalan_book_app/features/chalan/bloc/filter_event.dart';
import 'package:chalan_book_app/features/chalan/bloc/filter_state.dart';
import 'package:chalan_book_app/features/chalan/models/advanced_filter_model.dart';
import 'package:chalan_book_app/features/chalan/widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdvancedSearchBar extends StatefulWidget {
  const AdvancedSearchBar({super.key});

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final _searchController = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _showClearButton = _searchController.text.isNotEmpty;

    context.read<FilterBloc>().add(
      UpdateSearchQueryEvent(_searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withAlpha(25),
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Search bar (expanded)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: context.colors.outline),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.translate('search_chalans'),
                          prefixIcon: Icon(
                            Icons.search,
                            color: context.colors.onSurfaceVariant,
                          ),
                          suffixIcon: _showClearButton
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 16.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  // _buildActionButton(
                  //   icon: Icons.filter_list,
                  //   hasActiveFilters: state.filter.hasActiveFilters,
                  //   onPressed: _showFilterBottomSheet,
                  // ),
                  // 8.horizontalSpace,
                  _buildActionButton(
                    icon: state.filter.sortOrder == SortOrder.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    hasActiveFilters:
                        state.filter.sortOrder != SortOrder.descending ||
                        state.filter.sortBy != SortBy.createdAt,
                    onPressed: _toggleSortOrder,
                  ),
                ],
              ),
              gap.h12,
              if (state.filter.hasActiveFilters) ...[
                _buildActiveFiltersChips(state),
                gap.h8,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _clearAllFilters,
                    icon: Icon(Icons.clear_all, size: 18.w,),
                    label: Text(l10n.translate('clear_all')),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

 Widget _buildActionButton({
  required IconData icon,
  required VoidCallback onPressed,
  bool hasActiveFilters = false,
}) {
  return SizedBox(
    height: 48.h,
    width: 48.h,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? context.colors.primary.withOpacity(0.1)
              : context.colors.surface,
          border: Border.all(
            color: hasActiveFilters
                ? context.colors.primary
                : context.colors.outline,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18.w,
          color: hasActiveFilters
              ? context.colors.primary
              : context.colors.onSurface,
        ),
      ),
    ),
  );
}

  Widget _buildActiveFiltersChips(FilterState state) {
    final filter = state.filter;
    final chips = <Widget>[];

    if (filter.fromDate != null || filter.toDate != null) {
      chips.add(
        _buildFilterChip(
          label: _getDateRangeText(filter),
          onRemove: () {
            context.read<FilterBloc>().add(
              SetDateRangeFilterEvent(fromDate: null, toDate: null),
            );
          },
        ),
      );
    }

    if (filter.selectedMonth != null) {
      chips.add(
        _buildFilterChip(
          label: _getMonthText(filter),
          onRemove: () {
            context.read<FilterBloc>().add(SetMonthFilterEvent(month: null));
          },
        ),
      );
    }

    if (filter.fromChalanNumber != null || filter.toChalanNumber != null) {
      chips.add(
        _buildFilterChip(
          label: _getChalanRangeText(filter),
          onRemove: () {
            context.read<FilterBloc>().add(
              SetChalanNumberRangeFilterEvent(fromNumber: null, toNumber: null),
            );
          },
        ),
      );
    }

    if (filter.createdByFilter != CreatedByFilter.all) {
      chips.add(
        _buildFilterChip(
          label: filter.createdByFilter.toString().split('.').last,
          onRemove: () {
            context.read<FilterBloc>().add(
              SetCreatedByFilterEvent(CreatedByFilter.all),
            );
          },
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            chips[i],
            if (i < chips.length - 1) 8.horizontalSpace,
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Chip(
      label: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      deleteIcon: Icon(Icons.close, size: 16.w),
      onDeleted: onRemove,
      backgroundColor: context.colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }

  String _getDateRangeText(AdvancedChalanFilter filter) {
    if (filter.fromDate != null && filter.toDate != null) {
      return '📅 ${_formatDate(filter.fromDate!)} - ${_formatDate(filter.toDate!)}';
    } else if (filter.fromDate != null) {
      return '📅 From ${_formatDate(filter.fromDate!)}';
    } else {
      return '📅 Until ${_formatDate(filter.toDate!)}';
    }
  }

  String _getMonthText(AdvancedChalanFilter filter) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '🗓️ ${months[filter.selectedMonth! - 1]} ${filter.selectedYear}';
  }

  String _getChalanRangeText(AdvancedChalanFilter filter) {
    if (filter.fromChalanNumber != null && filter.toChalanNumber != null) {
      return '🔢 #${filter.fromChalanNumber} - #${filter.toChalanNumber}';
    } else if (filter.fromChalanNumber != null) {
      return '🔢 From #${filter.fromChalanNumber}';
    } else {
      return '🔢 Up to #${filter.toChalanNumber}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.outline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(child: FilterBottomSheet()),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSortOrder() {
    final bloc = context.read<FilterBloc>();
    final currentOrder = bloc.state.filter.sortOrder;
    bloc.add(
      ChangeSortOrderEvent(
        currentOrder == SortOrder.ascending
            ? SortOrder.descending
            : SortOrder.ascending,
      ),
    );
    bloc.add(ApplyFiltersEvent());
  }

  void _clearAllFilters() {
    _searchController.clear();
    context.read<FilterBloc>().add(ClearAllFiltersEvent());
  }
}
