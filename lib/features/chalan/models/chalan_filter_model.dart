enum SortOrder { ascending, descending }

class ChalanFilter {
  final String searchQuery;
  final SortOrder sortOrder;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minChalanNumber;
  final int? maxChalanNumber;
  final String? createdBy;
  
  const ChalanFilter({
    this.searchQuery = '',
    this.sortOrder = SortOrder.descending,
    this.startDate,
    this.endDate,
    this.minChalanNumber,
    this.maxChalanNumber,
    this.createdBy,
  });
  
  bool get isActive {
    return searchQuery.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        minChalanNumber != null ||
        maxChalanNumber != null ||
        createdBy != null;
  }
  
  ChalanFilter copyWith({
    String? searchQuery,
    SortOrder? sortOrder,
    DateTime? startDate,
    DateTime? endDate,
    int? minChalanNumber,
    int? maxChalanNumber,
    String? createdBy,
    bool clearDates = false,
    bool clearNumbers = false,
    bool clearCreatedBy = false,
  }) {
    return ChalanFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      minChalanNumber: clearNumbers ? null : (minChalanNumber ?? this.minChalanNumber),
      maxChalanNumber: clearNumbers ? null : (maxChalanNumber ?? this.maxChalanNumber),
      createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
    );
  }
  
  ChalanFilter clear() {
    return const ChalanFilter();
  }
}
