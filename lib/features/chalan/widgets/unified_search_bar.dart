// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// import '../../../core/extensions/context_extension.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../bloc/unified_chalan_bloc.dart';
// import '../models/unified_chalan_filter.dart';
// import 'unified_filter_bottom_sheet.dart';

// class UnifiedSearchBar extends StatefulWidget {
//   const UnifiedSearchBar({super.key});

//   @override
//   State<UnifiedSearchBar> createState() => _UnifiedSearchBarState();
// }

// class _UnifiedSearchBarState extends State<UnifiedSearchBar> {
//   final _searchController = TextEditingController();
//   bool _showClearButton = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _showClearButton = _searchController.text.isNotEmpty;
//     });
    
//     context.read<UnifiedChalanBloc>().add(
//       UpdateSearchQueryEvent(_searchController.text),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<UnifiedChalanBloc, UnifiedChalanState>(
//       builder: (context, state) {
//         final filter = state is UnifiedChalanLoaded ? state.filter : const UnifiedChalanFilter();
        
//         return Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: context.colors.surface,
//             boxShadow: [
//               BoxShadow(
//                 color: context.colors.shadow.withOpacity(0.1),
//                 blurRadius: 4.r,
//                 offset: Offset(0, 2.h),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Search bar
//               Container(
//                 decoration: BoxDecoration(
//                   color: context.colors.surfaceVariant,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: context.t.searchChalans,
//                     prefixIcon: Icon(
//                       Icons.search,
//                       color: context.colors.onSurfaceVariant,
//                     ),
//                     suffixIcon: _showClearButton
//                         ? IconButton(
//                             icon: Icon(
//                               Icons.clear,
//                               color: context.colors.onSurfaceVariant,
//                             ),
//                             onPressed: () {
//                               _searchController.clear();
//                             },
//                           )
//                         : null,
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(
//                       vertical: 12.h,
//                       horizontal: 16.w,
//                     ),
//                   ),
//                 ),
//               ),
              
//               12.verticalSpace,
              
//               // Filter and sort buttons
//               Row(
//                 children: [
//                   _buildActionButton(
//                     icon: Icons.filter_list,
//                     label: context.t.filter,
//                     hasActiveFilters: filter.hasActiveFilters,
//                     onPressed: _showFilterBottomSheet,
//                   ),
//                   12.horizontalSpace,
//                   _buildActionButton(
//                     icon: filter.sortOrder == SortOrder.ascending
//                         ? Icons.arrow_upward
//                         : Icons.arrow_downward,
//                     label: filter.sortOrder == SortOrder.ascending
//                         ? context.t.ascending
//                         : context.t.descending,
//                     hasActiveFilters: filter.sortOrder != SortOrder.ascending ||
//                         filter.sortBy != SortBy.chalanNumber,
//                     onPressed: _toggleSortOrder,
//                   ),
//                   const Spacer(),
//                   if (filter.hasActiveFilters)
//                     TextButton.icon(
//                       onPressed: _clearAllFilters,
//                       icon: Icon(
//                         Icons.clear_all,
//                         size: 18.w,
//                       ),
//                       label: Text(context.t.clearAll),
//                       style: TextButton.styleFrom(
//                         foregroundColor: context.colors.primary,
//                       ),
//                     ),
//                 ],
//               ),
              
//               // Active filters chips
//               if (filter.hasActiveFilters) ...[
//                 12.verticalSpace,
//                 _buildActiveFiltersChips(filter),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//     bool hasActiveFilters = false,
//   }) {
//     return OutlinedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(
//         icon,
//         size: 18.w,
//         color: hasActiveFilters ? context.colors.primary : context.colors.onSurface,
//       ),
//       label: Text(label),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: hasActiveFilters ? context.colors.primary : context.colors.onSurface,
//         side: BorderSide(
//           color: hasActiveFilters
//               ? context.colors.primary
//               : context.colors.outline,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//       ),
//     );
//   }

//   Widget _buildActiveFiltersChips(UnifiedChalanFilter filter) {
//     final chips = <Widget>[];
    
//     // Date range chip
//     if (filter.fromDate != null || filter.toDate != null) {
//       chips.add(_buildFilterChip(
//         label: _getDateRangeText(filter),
//         onRemove: () {
//           context.read<UnifiedChalanBloc>().add(
//             SetDateRangeFilterEvent(fromDate: null, toDate: null),
//           );
//         },
//       ));
//     }
    
//     // Month filter chip
//     if (filter.selectedMonth != null) {
//       chips.add(_buildFilterChip(
//         label: _getMonthText(filter),
//         onRemove: () {
//           context.read<UnifiedChalanBloc>().add(
//             SetMonthFilterEvent(month: null),
//           );
//         },
//       ));
//     }
    
//     // Chalan number range chip
//     if (filter.fromChalanNumber != null || filter.toChalanNumber != null) {
//       chips.add(_buildFilterChip(
//         label: _getChalanRangeText(filter),
//         onRemove: () {
//           context.read<UnifiedChalanBloc>().add(
//             SetChalanNumberRangeFilterEvent(fromNumber: null, toNumber: null),
//           );
//         },
//       ));
//     }
    
//     // Created by chip
//     if (filter.createdByFilter != CreatedByFilter.all) {
//       chips.add(_buildFilterChip(
//         label: '${filter.createdByFilter.emoji} ${filter.createdByFilter.displayName}',
//         onRemove: () {
//           context.read<UnifiedChalanBloc>().add(
//             SetCreatedByFilterEvent(CreatedByFilter.all),
//           );
//         },
//       ));
//     }
    
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           for (int i = 0; i < chips.length; i++) ...[
//             chips[i],
//             if (i < chips.length - 1) 8.horizontalSpace,
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip({
//     required String label,
//     required VoidCallback onRemove,
//   }) {
//     return Chip(
//       label: Text(
//         label,
//         style: context.textTheme.bodySmall?.copyWith(
//           color: context.colors.onSurfaceVariant,
//         ),
//       ),
//       deleteIcon: Icon(
//         Icons.close,
//         size: 16.w,
//       ),
//       onDeleted: onRemove,
//       backgroundColor: context.colors.surfaceVariant,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.r),
//       ),
//     );
//   }

//   String _getDateRangeText(UnifiedChalanFilter filter) {
//     if (filter.fromDate != null && filter.toDate != null) {
//       return '📅 ${_formatDate(filter.fromDate!)} - ${_formatDate(filter.toDate!)}';
//     } else if (filter.fromDate != null) {
//       return '📅 From ${_formatDate(filter.fromDate!)}';
//     } else {
//       return '📅 Until ${_formatDate(filter.toDate!)}';
//     }
//   }

//   String _getMonthText(UnifiedChalanFilter filter) {
//     final months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
    
//     return '🗓️ ${months[filter.selectedMonth! - 1]} ${filter.selectedYear}';
//   }

//   String _getChalanRangeText(UnifiedChalanFilter filter) {
//     if (filter.fromChalanNumber != null && filter.toChalanNumber != null) {
//       return '🔢 #${filter.fromChalanNumber} - #${filter.toChalanNumber}';
//     } else if (filter.fromChalanNumber != null) {
//       return '🔢 From #${filter.fromChalanNumber}';
//     } else {
//       return '🔢 Up to #${filter.toChalanNumber}';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   void _showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: context.colors.background,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//           ),
//           child: Column(
//             children: [
//               // Drag handle
//               Container(
//                 margin: EdgeInsets.symmetric(vertical: 8.h),
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: context.colors.outline,
//                   borderRadius: BorderRadius.circular(2.r),
//                 ),
//               ),
              
//               // Filter content
//               const Expanded(
//                 child: UnifiedFilterBottomSheet(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _toggleSortOrder() {
//     final bloc = context.read<UnifiedChalanBloc>();
//     final currentState = bloc.state;
    
//     if (currentState is UnifiedChalanLoaded) {
//       final currentOrder = currentState.filter.sortOrder;
      
//       bloc.add(ChangeSortOrderEvent(
//         currentOrder == SortOrder.ascending
//             ? SortOrder.descending
//             : SortOrder.ascending,
//       ));
//     }
//   }

//   void _clearAllFilters() {
//     _searchController.clear();
//     context.read<UnifiedChalanBloc>().add(ClearAllFiltersEvent());
//   }
// }
