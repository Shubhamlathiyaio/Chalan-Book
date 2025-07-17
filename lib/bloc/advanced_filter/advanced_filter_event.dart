import 'package:chalan_book_app/features/filter/advanced_filter_model.dart';

/// Base class for all advanced filter events
abstract class AdvancedChalanFilterEvent {}

/// Event to update search query with smart detection
class UpdateSearchQueryEvent extends AdvancedChalanFilterEvent {
  final String query;
  UpdateSearchQueryEvent(this.query);
}

/// Event to set date range filter
class SetDateRangeFilterEvent extends AdvancedChalanFilterEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  
  SetDateRangeFilterEvent({this.fromDate, this.toDate});
}

/// Event to set chalan number range filter
class SetChalanNumberRangeFilterEvent extends AdvancedChalanFilterEvent {
  final int? fromNumber;
  final int? toNumber;
  
  SetChalanNumberRangeFilterEvent({this.fromNumber, this.toNumber});
}

/// Event to set created by filter
class SetCreatedByFilterEvent extends AdvancedChalanFilterEvent {
  final CreatedByFilter filter;
  SetCreatedByFilterEvent(this.filter);
}

/// Event to set month filter
class SetMonthFilterEvent extends AdvancedChalanFilterEvent {
  final int? month;
  final int? year;
  
  SetMonthFilterEvent({this.month, this.year});
}

/// Event to change sort order
class ChangeSortOrderEvent extends AdvancedChalanFilterEvent {
  final SortOrder sortOrder;
  ChangeSortOrderEvent(this.sortOrder);
}

/// Event to change sort by
class ChangeSortByEvent extends AdvancedChalanFilterEvent {
  final SortBy sortBy;
  ChangeSortByEvent(this.sortBy);
}

/// Event to clear all filters
class ClearAllFiltersEvent extends AdvancedChalanFilterEvent {}

/// Event to apply filters
class ApplyFiltersEvent extends AdvancedChalanFilterEvent {}
