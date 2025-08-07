import 'package:chalan_book_app/features/shared/local_bg/preference_helper.dart';

class AdvancedChalanFilter {
  final String searchQuery;
  final SearchType searchType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? fromChalanNumber;
  final int? toChalanNumber;
  final CreatedByFilter createdByFilter;
  final int? selectedMonth;
  final int? selectedYear;
  final SortOrder sortOrder;
  final SortBy sortBy;

  const AdvancedChalanFilter({
    this.searchQuery = '',
    this.searchType = SearchType.chalanNumber,
    this.fromDate,
    this.toDate,
    this.fromChalanNumber,
    this.toChalanNumber,
    this.createdByFilter = CreatedByFilter.all,
    this.selectedMonth,
    this.selectedYear,
    this.sortOrder = SortOrder.descending,
    this.sortBy = SortBy.createdAt,
  });

  /// Create a copy with updated values
  AdvancedChalanFilter copyWith({
    String? searchQuery,
    SearchType? searchType,
    DateTime? fromDate,
    DateTime? toDate,
    int? fromChalanNumber,
    int? toChalanNumber,
    CreatedByFilter? createdByFilter,
    int? selectedMonth,
    int? selectedYear,
    SortOrder sortOrder = SortOrder.ascending,
    SortBy? sortBy,
    bool clearDateRange = false,
    bool clearChalanRange = false,
    bool clearMonth = false,
  }) {
    return AdvancedChalanFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      searchType: searchType ?? this.searchType,
      fromDate: clearDateRange ? null : (fromDate ?? this.fromDate),
      toDate: clearDateRange ? null : (toDate ?? this.toDate),
      fromChalanNumber: clearChalanRange ? null : (fromChalanNumber ?? this.fromChalanNumber),
      toChalanNumber: clearChalanRange ? null : (toChalanNumber ?? this.toChalanNumber),
      createdByFilter: createdByFilter ?? this.createdByFilter,
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      selectedYear: clearMonth ? null : (selectedYear ?? this.selectedYear),
      sortOrder: sortOrder ?? this.sortOrder,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        fromDate != null ||
        toDate != null ||
        fromChalanNumber != null ||
        toChalanNumber != null ||
        createdByFilter != CreatedByFilter.all ||
        selectedMonth != null;
  }

  /// Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (fromDate != null || toDate != null) count++;
    if (fromChalanNumber != null || toChalanNumber != null) count++;
    if (createdByFilter != CreatedByFilter.all) count++;
    if (selectedMonth != null) count++;
    return count;
  }
}

/// Search type based on input pattern
enum SearchType {
  chalanNumber,
  date,
}

/// Created by filter options
enum CreatedByFilter {
  all,
  owner,
  member,
  me;
}

/// Sort order options
enum SortOrder {
  ascending,
  descending,
}

/// Sort by options
enum SortBy {
  createdAt,
  chalanNumber,
  dateTime,
}

/// Extension for CreatedByFilter
extension CreatedByFilterExtension on CreatedByFilter {
  String get displayName {
    switch (this) {
      case CreatedByFilter.all:
        return 'All';
      case CreatedByFilter.owner:
        return 'Owner';
      case CreatedByFilter.member:
        return 'Member';
      case CreatedByFilter.me:
        return 'Me';
    }
  }

  String get emoji {
    switch (this) {
      case CreatedByFilter.all:
        return '👥';
      case CreatedByFilter.owner:
        return '👑';
      case CreatedByFilter.member:
        return '👤';
      case CreatedByFilter.me:
        return '🙋‍♂️';
    }
  }
}
