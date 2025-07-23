// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// import '../../../core/extensions/context_extension.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../bloc/unified_chalan_bloc.dart';
// import '../models/unified_chalan_filter.dart';

// class UnifiedFilterBottomSheet extends StatefulWidget {
//   const UnifiedFilterBottomSheet({super.key});

//   @override
//   State<UnifiedFilterBottomSheet> createState() =>
//       _UnifiedFilterBottomSheetState();
// }

// class _UnifiedFilterBottomSheetState extends State<UnifiedFilterBottomSheet> {
//   final _fromNumberController = TextEditingController();
//   final _toNumberController = TextEditingController();
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   int? _selectedMonth;
//   int? _selectedYear;
//   CreatedByFilter _createdByFilter = CreatedByFilter.all;
//   SortOrder _sortOrder = SortOrder.ascending;
//   SortBy _sortBy = SortBy.chalanNumber;

//   @override
//   void initState() {
//     super.initState();
//     _initializeFilters();
//   }

//   void _initializeFilters() {
//     final state = context.read<UnifiedChalanBloc>().state;
//     if (state is UnifiedChalanLoaded) {
//       final filter = state.filter;

//       _fromNumberController.text = filter.fromChalanNumber?.toString() ?? '';
//       _toNumberController.text = filter.toChalanNumber?.toString() ?? '';
//       _fromDate = filter.fromDate;
//       _toDate = filter.toDate;
//       _selectedMonth = filter.selectedMonth;
//       _selectedYear = filter.selectedYear ?? DateTime.now().year;
//       _createdByFilter = filter.createdByFilter;
//       _sortOrder = filter.sortOrder;
//       _sortBy = filter.sortBy;
//     }
//   }

//   @override
//   void dispose() {
//     _fromNumberController.dispose();
//     _toNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<UnifiedChalanBloc, UnifiedChalanState>(
//       builder: (context, state) {
//         return Container(
//           padding: EdgeInsets.all(16.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 children: [
//                   Text(
//                     context.t.filters,
//                     style: context.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   TextButton(
//                     onPressed: _clearAllFilters,
//                     child: Text(context.t.clearAll),
//                   ),
//                 ],
//               ),
//               16.verticalSpace,

//               // Scrollable content
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Date Range Filter
//                       _buildSectionTitle(context.t.dateRange),
//                       8.verticalSpace,
//                       _buildDateRangeFilter(),
//                       16.verticalSpace,

//                       // Month Filter
//                       _buildSectionTitle(context.t.monthFilter),
//                       8.verticalSpace,
//                       _buildMonthFilter(),
//                       16.verticalSpace,

//                       // Chalan Number Range
//                       _buildSectionTitle(context.t.chalanNumberRange),
//                       8.verticalSpace,
//                       _buildChalanNumberRangeFilter(),
//                       16.verticalSpace,

//                       // Created By Filter
//                       _buildSectionTitle(context.t.createdBy),
//                       8.verticalSpace,
//                       _buildCreatedByFilter(),
//                       16.verticalSpace,

//                       // Sort Options
//                       _buildSectionTitle(context.t.sortOptions),
//                       8.verticalSpace,
//                       _buildSortOptions(),
//                     ],
//                   ),
//                 ),
//               ),

//               16.verticalSpace,

//               // Apply Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _applyFilters,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: context.colors.primary,
//                     foregroundColor: context.colors.onPrimary,
//                     padding: EdgeInsets.symmetric(vertical: 12.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                   child: Text(
//                     context.t.applyFilters,
//                     style: context.textTheme.titleMedium?.copyWith(
//                       color: context.colors.onPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: context.textTheme.titleMedium?.copyWith(
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   Widget _buildDateRangeFilter() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildDateSelector(
//             label: context.t.fromDate,
//             date: _fromDate,
//             onSelect: (date) {
//               setState(() => _fromDate = date);
//             },
//           ),
//         ),
//         16.horizontalSpace,
//         Expanded(
//           child: _buildDateSelector(
//             label: context.t.toDate,
//             date: _toDate,
//             onSelect: (date) {
//               setState(() => _toDate = date);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateSelector({
//     required String label,
//     required DateTime? date,
//     required Function(DateTime?) onSelect,
//   }) {
//     final dateFormat = DateFormat('dd/MM/yyyy');

//     return GestureDetector(
//       onTap: () async {
//         final selectedDate = await showDatePicker(
//           context: context,
//           initialDate: date ?? DateTime.now(),
//           firstDate: DateTime(2020),
//           lastDate: DateTime(2030),
//           builder: (context, child) {
//             return Theme(
//               data: Theme.of(context).copyWith(
//                 colorScheme: ColorScheme.light(
//                   primary: context.colors.primary,
//                   onPrimary: context.colors.onPrimary,
//                   surface: context.colors.surface,
//                   onSurface: context.colors.onSurface,
//                 ),
//               ),
//               child: child!,
//             );
//           },
//         );

//         if (selectedDate != null) {
//           onSelect(selectedDate);
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//         decoration: BoxDecoration(
//           border: Border.all(color: context.colors.outline),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: context.textTheme.bodySmall?.copyWith(
//                       color: context.colors.onSurfaceVariant,
//                     ),
//                   ),
//                   4.verticalSpace,
//                   Text(
//                     date != null ? dateFormat.format(date) : 'Select',
//                     style: context.textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.calendar_today,
//               size: 20.w,
//               color: context.colors.primary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthFilter() {
//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Year selector
//         DropdownButtonFormField<int>(
//           value: _selectedYear,
//           decoration: InputDecoration(
//             labelText: context.t.year,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 12.h,
//             ),
//           ),
//           items: List.generate(5, (index) {
//             final year = DateTime.now().year - 2 + index;
//             return DropdownMenuItem(value: year, child: Text(year.toString()));
//           }),
//           onChanged: (value) {
//             setState(() => _selectedYear = value);
//           },
//         ),
//         12.verticalSpace,

//         // Month chips
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: List.generate(12, (index) {
//             final month = index + 1;
//             final isSelected = _selectedMonth == month;

//             return FilterChip(
//               label: Text(months[index]),
//               selected: isSelected,
//               onSelected: (selected) {
//                 setState(() {
//                   _selectedMonth = selected ? month : null;
//                 });
//               },
//               backgroundColor: context.colors.surfaceContainerHighest,
//               selectedColor: context.colors.primary.withOpacity(0.2),
//               checkmarkColor: context.colors.primary,
//               labelStyle: context.textTheme.bodyMedium?.copyWith(
//                 color: isSelected
//                     ? context.colors.primary
//                     : context.colors.onSurfaceVariant,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//                 side: BorderSide(
//                   color: isSelected
//                       ? context.colors.primary
//                       : Colors.transparent,
//                 ),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   Widget _buildChalanNumberRangeFilter() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _fromNumberController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: context.t.fromNumber,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 12.w,
//                 vertical: 12.h,
//               ),
//             ),
//           ),
//         ),
//         16.horizontalSpace,
//         Expanded(
//           child: TextFormField(
//             controller: _toNumberController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: context.t.toNumber,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 12.w,
//                 vertical: 12.h,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCreatedByFilter() {
//     return Wrap(
//       spacing: 8.w,
//       runSpacing: 8.h,
//       children: CreatedByFilter.values.map((filter) {
//         final isSelected = _createdByFilter == filter;

//         return FilterChip(
//           label: Text('${filter.emoji} ${filter.displayName}'),
//           selected: isSelected,
//           onSelected: (selected) {
//             setState(() {
//               _createdByFilter = selected ? filter : CreatedByFilter.all;
//             });
//           },
//           backgroundColor: context.colors.surfaceContainerHighest,
//           selectedColor: context.colors.primary.withOpacity(0.2),
//           checkmarkColor: context.colors.primary,
//           labelStyle: context.textTheme.bodyMedium?.copyWith(
//             color: isSelected
//                 ? context.colors.primary
//                 : context.colors.onSurfaceVariant,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//             side: BorderSide(
//               color: isSelected ? context.colors.primary : Colors.transparent,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSortOptions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Sort by
//         Text(
//           context.t.sortBy,
//           style: context.textTheme.bodyMedium?.copyWith(
//             color: context.colors.onSurfaceVariant,
//           ),
//         ),
//         8.verticalSpace,
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: [
//             _buildSortByOption(SortBy.createdAt, context.t.createdDate),
//             _buildSortByOption(SortBy.chalanNumber, context.t.chalanNumber),
//             _buildSortByOption(SortBy.dateTime, context.t.date),
//           ],
//         ),
//         16.verticalSpace,

//         // Sort order
//         Text(
//           context.t.sortOrder,
//           style: context.textTheme.bodyMedium?.copyWith(
//             color: context.colors.onSurfaceVariant,
//           ),
//         ),
//         8.verticalSpace,
//         Row(
//           children: [
//             _buildSortOrderOption(
//               SortOrder.ascending,
//               context.t.ascending,
//               Icons.arrow_upward,
//             ),
//             16.horizontalSpace,
//             _buildSortOrderOption(
//               SortOrder.descending,
//               context.t.descending,
//               Icons.arrow_downward,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSortByOption(SortBy sortBy, String label) {
//     final isSelected = _sortBy == sortBy;

//     return ChoiceChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (selected) {
//         if (selected) {
//           setState(() => _sortBy = sortBy);
//         }
//       },
//       backgroundColor: context.colors.surfaceContainerHighest,
//       selectedColor: context.colors.primary.withOpacity(0.2),
//       labelStyle: context.textTheme.bodyMedium?.copyWith(
//         color: isSelected
//             ? context.colors.primary
//             : context.colors.onSurfaceVariant,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.r),
//         side: BorderSide(
//           color: isSelected ? context.colors.primary : Colors.transparent,
//         ),
//       ),
//     );
//   }

//   Widget _buildSortOrderOption(SortOrder order, String label, IconData icon) {
//     final isSelected = _sortOrder == order;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() => _sortOrder = order);
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? context.colors.primary.withOpacity(0.1)
//                 : context.colors.surfaceContainerHighest,
//             borderRadius: BorderRadius.circular(8.r),
//             border: Border.all(
//               color: isSelected ? context.colors.primary : Colors.transparent,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 18.w,
//                 color: isSelected
//                     ? context.colors.primary
//                     : context.colors.onSurfaceVariant,
//               ),
//               8.horizontalSpace,
//               Text(
//                 label,
//                 style: context.textTheme.bodyMedium?.copyWith(
//                   color: isSelected
//                       ? context.colors.primary
//                       : context.colors.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _clearAllFilters() {
//     setState(() {
//       _fromNumberController.clear();
//       _toNumberController.clear();
//       _fromDate = null;
//       _toDate = null;
//       _selectedMonth = null;
//       _selectedYear = DateTime.now().year;
//       _createdByFilter = CreatedByFilter.all;
//       _sortOrder = SortOrder.ascending;
//       _sortBy = SortBy.chalanNumber;
//     });

//     context.read<UnifiedChalanBloc>().add(ClearAllFiltersEvent());
//     Navigator.pop(context);
//   }

//   void _applyFilters() {
//     final bloc = context.read<UnifiedChalanBloc>();

//     // Apply date range filter
//     if (_fromDate != null || _toDate != null) {
//       bloc.add(SetDateRangeFilterEvent(fromDate: _fromDate, toDate: _toDate));
//     }

//     // Apply month filter
//     if (_selectedMonth != null) {
//       bloc.add(SetMonthFilterEvent(month: _selectedMonth, year: _selectedYear));
//     }

//     // Apply chalan number range filter
//     final fromNumber = int.tryParse(_fromNumberController.text);
//     final toNumber = int.tryParse(_toNumberController.text);
//     if (fromNumber != null || toNumber != null) {
//       bloc.add(
//         SetChalanNumberRangeFilterEvent(
//           fromNumber: fromNumber,
//           toNumber: toNumber,
//         ),
//       );
//     }

//     // Apply created by filter
//     bloc.add(SetCreatedByFilterEvent(_createdByFilter));

//     // Apply sort options
//     bloc.add(ChangeSortOrderEvent(_sortOrder));
//     bloc.add(ChangeSortByEvent(_sortBy));

//     Navigator.pop(context);
//   }
// }
