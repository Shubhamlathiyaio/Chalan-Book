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
import 'filter_bottom_sheet.dart';

/// Advanced search bar with filter and sort buttons
class AdvancedSearchBar extends StatefulWidget {
  const AdvancedSearchBar({super.key});

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvancedChalanFilterBloc, AdvancedChalanFilterState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withOpacity(0.1),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search TextField
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: context.colors.outline.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: poppins.w400.fs14.textColor(context.colors.onSurface),
                    decoration: InputDecoration(
                      hintText: _getHintText(state.filter.searchType),
                      hintStyle: poppins.w400.fs14.textColor(
                        context.colors.onSurface.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        _getSearchIcon(state.filter.searchType),
                        color: context.colors.primary,
                        size: 20.w,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<AdvancedChalanFilterBloc>().add(
                                  UpdateSearchQueryEvent(''),
                                );
                              },
                              icon: Icon(
                                Icons.clear,
                                color: context.colors.onSurface.withOpacity(0.6),
                                size: 18.w,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: (query) {
                      context.read<AdvancedChalanFilterBloc>().add(
                        UpdateSearchQueryEvent(query),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Filter Button
              _buildFilterButton(context, state),

              SizedBox(width: 8.w),

              // Sort Button
              _buildSortButton(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Get hint text based on search type
  String _getHintText(SearchType searchType) {
    switch (searchType) {
      case SearchType.chalanNumber:
        return 'Search by chalan number...';
      case SearchType.date:
        return 'Search by date (15/7/2025)...';
    }
  }

  /// Get search icon based on search type
  IconData _getSearchIcon(SearchType searchType) {
    switch (searchType) {
      case SearchType.chalanNumber:
        return Icons.receipt_long;
      case SearchType.date:
        return Icons.calendar_today;
    }
  }

  /// Build filter button
  Widget _buildFilterButton(BuildContext context, AdvancedChalanFilterState state) {
    final hasActiveFilters = state.filter.hasActiveFilters;
    final filterCount = state.filter.activeFilterCount;

    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: hasActiveFilters 
              ? context.colors.primary.withOpacity(0.1)
              : context.colors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasActiveFilters 
                ? context.colors.primary
                : context.colors.outline.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            Icon(
              Icons.tune,
              color: hasActiveFilters 
                  ? context.colors.primary
                  : context.colors.onSurface.withOpacity(0.7),
              size: 20.w,
            ),
            if (hasActiveFilters && filterCount > 0)
              Positioned(
                right: -2.w,
                top: -2.h,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.xff002568,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.w,
                    minHeight: 16.h,
                  ),
                  child: Text(
                    filterCount.toString(),
                    style: poppins.w600.fs10.textColor(Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build sort button
  Widget _buildSortButton(BuildContext context, AdvancedChalanFilterState state) {
    final isAscending = state.filter.sortOrder == SortOrder.ascending;

    return GestureDetector(
      onTap: () => _toggleSortOrder(context, state.filter.sortOrder),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: context.colors.outline.withOpacity(0.3),
          ),
        ),
        child: Icon(
          isAscending ? Icons.arrow_upward : Icons.arrow_downward,
          color: context.colors.onSurface.withOpacity(0.7),
          size: 20.w,
        ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  /// Toggle sort order
  void _toggleSortOrder(BuildContext context, SortOrder currentOrder) {
    final newOrder = currentOrder == SortOrder.ascending 
        ? SortOrder.descending 
        : SortOrder.ascending;
    
    context.read<AdvancedChalanFilterBloc>().add(
      ChangeSortOrderEvent(newOrder),
    );
  }
}
