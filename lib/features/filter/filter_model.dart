import '../../../core/models/organization.dart';

/// Enum for different filter types
enum FilterType {
  thisYear,
  allYears,
  byMonth,
  byDate,
  createdByMe,
  chalanNumberRange,
}

/// Enum for chalan number ranges
enum ChalanNumberRange {
  below20,
  between20And80,
  above80,
  all,
}

/// Filter model to hold all filter criteria
class ChalanFilter {
  final String searchQuery;
  final FilterType filterType;
  final DateTime? specificDate;
  final int? specificMonth;
  final int? specificYear;
  final String? createdByUserId;
  final ChalanNumberRange chalanNumberRange;
  final int? customMinNumber;
  final int? customMaxNumber;

  const ChalanFilter({
    this.searchQuery = '',
    this.filterType = FilterType.thisYear,
    this.specificDate,
    this.specificMonth,
    this.specificYear,
    this.createdByUserId,
    this.chalanNumberRange = ChalanNumberRange.all,
    this.customMinNumber,
    this.customMaxNumber,
  });

  /// Create a copy with updated values
  ChalanFilter copyWith({
    String? searchQuery,
    FilterType? filterType,
    DateTime? specificDate,
    int? specificMonth,
    int? specificYear,
    String? createdByUserId,
    ChalanNumberRange? chalanNumberRange,
    int? customMinNumber,
    int? customMaxNumber,
    bool clearDate = false,
    bool clearCreatedBy = false,
  }) {
    return ChalanFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      specificDate: clearDate ? null : (specificDate ?? this.specificDate),
      specificMonth: specificMonth ?? this.specificMonth,
      specificYear: specificYear ?? this.specificYear,
      createdByUserId: clearCreatedBy ? null : (createdByUserId ?? this.createdByUserId),
      chalanNumberRange: chalanNumberRange ?? this.chalanNumberRange,
      customMinNumber: customMinNumber ?? this.customMinNumber,
      customMaxNumber: customMaxNumber ?? this.customMaxNumber,
    );
  }

  /// Check if filter is active (not default)
  bool get isActive {
    return searchQuery.isNotEmpty ||
        filterType != FilterType.thisYear ||
        specificDate != null ||
        createdByUserId != null ||
        chalanNumberRange != ChalanNumberRange.all;
  }

  /// Get display text for current filter
  String get displayText {
    switch (filterType) {
      case FilterType.thisYear:
        return '📆 This Year';
      case FilterType.allYears:
        return '🔄 All Years';
      case FilterType.byMonth:
        return '🗓️ ${_getMonthName(specificMonth ?? DateTime.now().month)} ${specificYear ?? DateTime.now().year}';
      case FilterType.byDate:
        return '📅 ${specificDate?.day}/${specificDate?.month}/${specificDate?.year}';
      case FilterType.createdByMe:
        return '👤 Created By Me';
      case FilterType.chalanNumberRange:
        return '🔢 ${_getChalanRangeText()}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _getChalanRangeText() {
    switch (chalanNumberRange) {
      case ChalanNumberRange.below20:
        return 'Below 20';
      case ChalanNumberRange.between20And80:
        return '20-80';
      case ChalanNumberRange.above80:
        return 'Above 80';
      case ChalanNumberRange.all:
        return 'All Numbers';
    }
  }
}
