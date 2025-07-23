import '../models/advanced_filter_model.dart';

/// Base class for all advanced filter events
abstract class FilterEvent {}

/// Event to update search query with smart detection
class UpdateSearchQueryEvent extends FilterEvent {
  final String query;
  UpdateSearchQueryEvent(this.query);
}

/// Event to set date range filter
class SetDateRangeFilterEvent extends FilterEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  SetDateRangeFilterEvent({this.fromDate, this.toDate});
}

/// Event to set chalan number range filter
class SetChalanNumberRangeFilterEvent extends FilterEvent {
  final int? fromNumber;
  final int? toNumber;

  SetChalanNumberRangeFilterEvent({this.fromNumber, this.toNumber});
}

/// Event to set created by filter
class SetCreatedByFilterEvent extends FilterEvent {
  final CreatedByFilter filter;
  SetCreatedByFilterEvent(this.filter);
}

/// Event to set month filter
class SetMonthFilterEvent extends FilterEvent {
  final int? month;
  final int? year;

  SetMonthFilterEvent({this.month, this.year});
}

/// Event to change sort order
class ChangeSortOrderEvent extends FilterEvent {
  final SortOrder sortOrder;
  ChangeSortOrderEvent(this.sortOrder);
}

/// Event to change sort by
class ChangeSortByEvent extends FilterEvent {
  final SortBy sortBy;
  ChangeSortByEvent(this.sortBy);
}

/// Event to clear all filters
class ClearAllFiltersEvent extends FilterEvent {}

/// Event to apply filters
class ApplyFiltersEvent extends FilterEvent {}
