// import '../../models/chalan_filter.dart';

// /// Base class for all filter events
// abstract class ChalanFilterEvent {}

// /// Event to update search query with debounce
// class UpdateSearchQueryEvent extends ChalanFilterEvent {
//   final String query;
//   UpdateSearchQueryEvent(this.query);
// }

// /// Event to change filter type
// class ChangeFilterTypeEvent extends ChalanFilterEvent {
//   final FilterType filterType;
//   final DateTime? date;
//   final int? month;
//   final int? year;
  
//   ChangeFilterTypeEvent(
//     this.filterType, {
//     this.date,
//     this.month,
//     this.year,
//   });
// }

// /// Event to set created by filter
// class SetCreatedByFilterEvent extends ChalanFilterEvent {
//   final String? userId;
//   SetCreatedByFilterEvent(this.userId);
// }

// /// Event to set chalan number range filter
// class SetChalanNumberRangeEvent extends ChalanFilterEvent {
//   final ChalanNumberRange range;
//   final int? customMin;
//   final int? customMax;
  
//   SetChalanNumberRangeEvent(
//     this.range, {
//     this.customMin,
//     this.customMax,
//   });
// }

// /// Event to clear all filters
// class ClearAllFiltersEvent extends ChalanFilterEvent {}

// /// Event to apply filters to chalan list
// class ApplyFiltersEvent extends ChalanFilterEvent {}
