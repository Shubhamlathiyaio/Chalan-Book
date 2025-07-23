class Filter {
  // Custom fields
  final bool? isCredit;
  final bool? isCash;
  final bool? isPending;
  final bool? isCompleted;
  final bool? isRegular;
  final bool? isAdvance;
  final bool? isDeleted;
  final bool? isTodayOnly;

  // Advanced filter fields
  final String searchQuery;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? fromChalanNumber;
  final int? toChalanNumber;
  final int? selectedMonth;
  final int? selectedYear;
  final CreatedByFilter createdByFilter;
  final SortOrder sortOrder;
  final SortBy sortBy;

  const Filter({
    this.isCredit,
    this.isCash,
    this.isPending,
    this.isCompleted,
    this.isRegular,
    this.isAdvance,
    this.isDeleted,
    this.isTodayOnly,
    this.searchQuery = '',
    this.fromDate,
    this.toDate,
    this.fromChalanNumber,
    this.toChalanNumber,
    this.selectedMonth,
    this.selectedYear,
    this.createdByFilter = CreatedByFilter.all,
    this.sortOrder = SortOrder.descending,
    this.sortBy = SortBy.createdAt,
  });

  Filter copyWith({
    bool? isCredit,
    bool? isCash,
    bool? isPending,
    bool? isCompleted,
    bool? isRegular,
    bool? isAdvance,
    bool? isDeleted,
    bool? isTodayOnly,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
    int? fromChalanNumber,
    int? toChalanNumber,
    int? selectedMonth,
    int? selectedYear,
    CreatedByFilter? createdByFilter,
    SortOrder? sortOrder,
    SortBy? sortBy,
  }) {
    return Filter(
      isCredit: isCredit ?? this.isCredit,
      isCash: isCash ?? this.isCash,
      isPending: isPending ?? this.isPending,
      isCompleted: isCompleted ?? this.isCompleted,
      isRegular: isRegular ?? this.isRegular,
      isAdvance: isAdvance ?? this.isAdvance,
      isDeleted: isDeleted ?? this.isDeleted,
      isTodayOnly: isTodayOnly ?? this.isTodayOnly,
      searchQuery: searchQuery ?? this.searchQuery,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      fromChalanNumber: fromChalanNumber ?? this.fromChalanNumber,
      toChalanNumber: toChalanNumber ?? this.toChalanNumber,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      createdByFilter: createdByFilter ?? this.createdByFilter,
      sortOrder: sortOrder ?? this.sortOrder,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Filter clear() => const Filter();

  bool get isEmpty =>
      isCredit == null &&
      isCash == null &&
      isPending == null &&
      isCompleted == null &&
      isRegular == null &&
      isAdvance == null &&
      isDeleted == null &&
      isTodayOnly == null &&
      searchQuery.isEmpty &&
      fromDate == null &&
      toDate == null &&
      fromChalanNumber == null &&
      toChalanNumber == null &&
      selectedMonth == null &&
      selectedYear == null &&
      createdByFilter == CreatedByFilter.all &&
      sortOrder == SortOrder.descending &&
      sortBy == SortBy.createdAt;

  bool get hasActiveFilters =>
      !isEmpty;
}

enum CreatedByFilter { all, me, others }

extension CreatedByFilterLabel on CreatedByFilter {
  String get label {
    switch (this) {
      case CreatedByFilter.me:
        return 'Me';
      case CreatedByFilter.others:
        return 'Others';
      default:
        return 'All';
    }
  }
}

enum SortOrder { ascending, descending }
enum SortBy { createdAt, chalanNumber, custom }

