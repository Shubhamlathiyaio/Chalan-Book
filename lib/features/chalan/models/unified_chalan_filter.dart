enum SortOrder { ascending, descending }

enum SortBy { 
  chalanNumber, 
  createdAt, 
  dateTime 
}

enum SearchType { 
  chalanNumber, 
  date 
}

enum CreatedByFilter { 
  all, 
  me, 
  owner, 
  member 
}

extension CreatedByFilterExtension on CreatedByFilter {
  String get displayName {
    switch (this) {
      case CreatedByFilter.all:
        return 'All';
      case CreatedByFilter.me:
        return 'Me';
      case CreatedByFilter.owner:
        return 'Owner';
      case CreatedByFilter.member:
        return 'Members';
    }
  }

  String get emoji {
    switch (this) {
      case CreatedByFilter.all:
        return '👥';
      case CreatedByFilter.me:
        return '👤';
      case CreatedByFilter.owner:
        return '👑';
      case CreatedByFilter.member:
        return '🧑‍💼';
    }
  }
}

class UnifiedChalanFilter {
  // Search
  final String searchQuery;
  final SearchType searchType;
  
  // Sorting
  final SortOrder sortOrder;
  final SortBy sortBy;
  
  // Date filters
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? selectedMonth;
  final int? selectedYear;
  
  // Number filters
  final int? fromChalanNumber;
  final int? toChalanNumber;
  
  // User filters
  final CreatedByFilter createdByFilter;

  const UnifiedChalanFilter({
    this.searchQuery = '',
    this.searchType = SearchType.chalanNumber,
    this.sortOrder = SortOrder.ascending,
    this.sortBy = SortBy.chalanNumber,
    this.fromDate,
    this.toDate,
    this.selectedMonth,
    this.selectedYear,
    this.fromChalanNumber,
    this.toChalanNumber,
    this.createdByFilter = CreatedByFilter.all,
  });

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        fromDate != null ||
        toDate != null ||
        selectedMonth != null ||
        fromChalanNumber != null ||
        toChalanNumber != null ||
        createdByFilter != CreatedByFilter.all ||
        sortOrder != SortOrder.ascending ||
        sortBy != SortBy.chalanNumber;
  }

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (fromDate != null || toDate != null) count++;
    if (selectedMonth != null) count++;
    if (fromChalanNumber != null || toChalanNumber != null) count++;
    if (createdByFilter != CreatedByFilter.all) count++;
    return count;
  }

  UnifiedChalanFilter copyWith({
    String? searchQuery,
    SearchType? searchType,
    SortOrder? sortOrder,
    SortBy? sortBy,
    DateTime? fromDate,
    DateTime? toDate,
    int? selectedMonth,
    int? selectedYear,
    int? fromChalanNumber,
    int? toChalanNumber,
    CreatedByFilter? createdByFilter,
    bool clearDates = false,
    bool clearNumbers = false,
    bool clearMonth = false,
  }) {
    return UnifiedChalanFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      searchType: searchType ?? this.searchType,
      sortOrder: sortOrder ?? this.sortOrder,
      sortBy: sortBy ?? this.sortBy,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      selectedYear: clearMonth ? null : (selectedYear ?? this.selectedYear),
      fromChalanNumber: clearNumbers ? null : (fromChalanNumber ?? this.fromChalanNumber),
      toChalanNumber: clearNumbers ? null : (toChalanNumber ?? this.toChalanNumber),
      createdByFilter: createdByFilter ?? this.createdByFilter,
    );
  }

  UnifiedChalanFilter clear() {
    return const UnifiedChalanFilter();
  }
}
