// enum SearchType { chalanNumber, date }

// enum SortBy { chalanNumber, createdAt, dateTime }

// enum SortOrder { ascending, descending }

// enum CreatedByFilter { all, me, owner, member }

// class AdvancedChalanFilter {
//   final String searchQuery;
//   final SearchType searchType;
//   final DateTime? fromDate;
//   final DateTime? toDate;
//   final int? fromChalanNumber;
//   final int? toChalanNumber;
//   final CreatedByFilter createdByFilter;
//   final int? selectedMonth;
//   final int? selectedYear;
//   final SortBy sortBy;
//   final SortOrder sortOrder;

//   const AdvancedChalanFilter({
//     this.searchQuery = '',
//     this.searchType = SearchType.chalanNumber,
//     this.fromDate,
//     this.toDate,
//     this.fromChalanNumber,
//     this.toChalanNumber,
//     this.createdByFilter = CreatedByFilter.all,
//     this.selectedMonth,
//     this.selectedYear,
//     this.sortBy = SortBy.chalanNumber,
//     this.sortOrder = SortOrder.ascending,
//   });

//   AdvancedChalanFilter copyWith({
//     String? searchQuery,
//     SearchType? searchType,
//     DateTime? fromDate,
//     DateTime? toDate,
//     int? fromChalanNumber,
//     int? toChalanNumber,
//     CreatedByFilter? createdByFilter,
//     int? selectedMonth,
//     int? selectedYear,
//     SortBy? sortBy,
//     SortOrder? sortOrder,
//   }) {
//     return AdvancedChalanFilter(
//       searchQuery: searchQuery ?? this.searchQuery,
//       searchType: searchType ?? this.searchType,
//       fromDate: fromDate ?? this.fromDate,
//       toDate: toDate ?? this.toDate,
//       fromChalanNumber: fromChalanNumber ?? this.fromChalanNumber,
//       toChalanNumber: toChalanNumber ?? this.toChalanNumber,
//       createdByFilter: createdByFilter ?? this.createdByFilter,
//       selectedMonth: selectedMonth ?? this.selectedMonth,
//       selectedYear: selectedYear ?? this.selectedYear,
//       sortBy: sortBy ?? this.sortBy,
//       sortOrder: sortOrder ?? this.sortOrder,
//     );
//   }

//   bool get hasActiveFilters {
//     return searchQuery.isNotEmpty ||
//         fromDate != null ||
//         toDate != null ||
//         fromChalanNumber != null ||
//         toChalanNumber != null ||
//         createdByFilter != CreatedByFilter.all ||
//         selectedMonth != null;
//   }
// }
