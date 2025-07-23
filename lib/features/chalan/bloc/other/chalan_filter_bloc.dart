// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/models/chalan.dart';
// import '../../models/chalan_filter_model.dart';

// // Events
// abstract class ChalanFilterEvent {}

// class UpdateSearchQuery extends ChalanFilterEvent {
//   final String query;
//   UpdateSearchQuery(this.query);
// }

// class ChangeSortOrder extends ChalanFilterEvent {
//   final SortOrder sortOrder;
//   ChangeSortOrder(this.sortOrder);
// }

// class SetDateRange extends ChalanFilterEvent {
//   final DateTime? startDate;
//   final DateTime? endDate;
//   SetDateRange({this.startDate, this.endDate});
// }

// class SetChalanNumberRange extends ChalanFilterEvent {
//   final int? minNumber;
//   final int? maxNumber;
//   SetChalanNumberRange({this.minNumber, this.maxNumber});
// }

// class SetCreatedBy extends ChalanFilterEvent {
//   final String? createdBy;
//   SetCreatedBy(this.createdBy);
// }

// class ClearAllFilters extends ChalanFilterEvent {}

// class UpdateOriginalChalans extends ChalanFilterEvent {
//   final List<Chalan> chalans;
//   UpdateOriginalChalans(this.chalans);
// }

// // State
// class ChalanFilterState {
//   final List<Chalan> originalChalans;
//   final List<Chalan> filteredChalans;
//   final ChalanFilter filter;
  
//   const ChalanFilterState({
//     this.originalChalans = const [],
//     this.filteredChalans = const [],
//     this.filter = const ChalanFilter(),
//   });
  
//   ChalanFilterState copyWith({
//     List<Chalan>? originalChalans,
//     List<Chalan>? filteredChalans,
//     ChalanFilter? filter,
//   }) {
//     return ChalanFilterState(
//       originalChalans: originalChalans ?? this.originalChalans,
//       filteredChalans: filteredChalans ?? this.filteredChalans,
//       filter: filter ?? this.filter,
//     );
//   }
// }

// // BLoC
// class ChalanFilterBloc extends Bloc<ChalanFilterEvent, ChalanFilterState> {
//   Timer? _debounceTimer;

//   ChalanFilterBloc() : super(const ChalanFilterState()) {
//     on<UpdateSearchQuery>(_onUpdateSearchQuery);
//     on<ChangeSortOrder>(_onChangeSortOrder);
//     on<SetDateRange>(_onSetDateRange);
//     on<SetChalanNumberRange>(_onSetChalanNumberRange);
//     on<SetCreatedBy>(_onSetCreatedBy);
//     on<ClearAllFilters>(_onClearAllFilters);
//     on<UpdateOriginalChalans>(_onUpdateOriginalChalans);
//   }

//   @override
//   Future<void> close() {
//     _debounceTimer?.cancel();
//     return super.close();
//   }
  
//   void _onUpdateSearchQuery(UpdateSearchQuery event, Emitter<ChalanFilterState> emit) {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       if (!isClosed) {
//         final newFilter = state.filter.copyWith(searchQuery: event.query);
//         final filteredChalans = _applyFilters(state.originalChalans, newFilter);
//         emit(state.copyWith(filter: newFilter, filteredChalans: filteredChalans));
//       }
//     });
//   }
  
//   void _onChangeSortOrder(ChangeSortOrder event, Emitter<ChalanFilterState> emit) {
//     final newFilter = state.filter.copyWith(sortOrder: event.sortOrder);
//     final filteredChalans = _applyFilters(state.originalChalans, newFilter);
//     emit(state.copyWith(filter: newFilter, filteredChalans: filteredChalans));
//   }
  
//   void _onSetDateRange(SetDateRange event, Emitter<ChalanFilterState> emit) {
//     final newFilter = state.filter.copyWith(
//       startDate: event.startDate,
//       endDate: event.endDate,
//     );
//     final filteredChalans = _applyFilters(state.originalChalans, newFilter);
//     emit(state.copyWith(filter: newFilter, filteredChalans: filteredChalans));
//   }
  
//   void _onSetChalanNumberRange(SetChalanNumberRange event, Emitter<ChalanFilterState> emit) {
//     final newFilter = state.filter.copyWith(
//       minChalanNumber: event.minNumber,
//       maxChalanNumber: event.maxNumber,
//     );
//     final filteredChalans = _applyFilters(state.originalChalans, newFilter);
//     emit(state.copyWith(filter: newFilter, filteredChalans: filteredChalans));
//   }
  
//   void _onSetCreatedBy(SetCreatedBy event, Emitter<ChalanFilterState> emit) {
//     final newFilter = state.filter.copyWith(createdBy: event.createdBy);
//     final filteredChalans = _applyFilters(state.originalChalans, newFilter);
//     emit(state.copyWith(filter: newFilter, filteredChalans: filteredChalans));
//   }
  
//   void _onClearAllFilters(ClearAllFilters event, Emitter<ChalanFilterState> emit) {
//     const newFilter = ChalanFilter();
//     final filteredChalans = _applyFilters(state.originalChalans, newFilter);
//     emit(state.copyWith(filter: newFilter, filteredChalans: filteredChalans));
//   }
  
//   void _onUpdateOriginalChalans(UpdateOriginalChalans event, Emitter<ChalanFilterState> emit) {
//     final filteredChalans = _applyFilters(event.chalans, state.filter);
//     emit(state.copyWith(
//       originalChalans: event.chalans,
//       filteredChalans: filteredChalans,
//     ));
//   }
  
//   List<Chalan> _applyFilters(List<Chalan> chalans, ChalanFilter filter) {
//     List<Chalan> filtered = List.from(chalans);
    
//     // Search filter - smart detection
//     if (filter.searchQuery.isNotEmpty) {
//       filtered = filtered.where((chalan) {
//         final query = filter.searchQuery.toLowerCase();
        
//         // If query contains date separators, search in date only
//         if (query.contains('/') || query.contains('-')) {
//           final dateStr = '${chalan.dateTime.day}/${chalan.dateTime.month}/${chalan.dateTime.year}';
//           return dateStr.toLowerCase().contains(query);
//         } else {
//           // Otherwise, search in chalan number only
//           return chalan.chalanNumber.toLowerCase().contains(query);
//         }
//       }).toList();
//     }
    
//     // Date range filter
//     if (filter.startDate != null || filter.endDate != null) {
//       filtered = filtered.where((chalan) {
//         final date = chalan.dateTime;
//         final start = filter.startDate;
//         final end = filter.endDate;
        
//         if (start != null && end != null) {
//           return date.isAfter(start.subtract(const Duration(days: 1))) &&
//                  date.isBefore(end.add(const Duration(days: 1)));
//         } else if (start != null) {
//           return date.isAfter(start.subtract(const Duration(days: 1)));
//         } else if (end != null) {
//           return date.isBefore(end.add(const Duration(days: 1)));
//         }
//         return true;
//       }).toList();
//     }
    
//     // Chalan number range filter
//     if (filter.minChalanNumber != null || filter.maxChalanNumber != null) {
//       filtered = filtered.where((chalan) {
//         final num = int.tryParse(chalan.chalanNumber) ?? 0;
//         final min = filter.minChalanNumber ?? 0;
//         final max = filter.maxChalanNumber ?? double.maxFinite.toInt();
//         return num >= min && num <= max;
//       }).toList();
//     }
    
//     // Created by filter
//     if (filter.createdBy != null) {
//       filtered = filtered.where((chalan) => chalan.createdBy == filter.createdBy).toList();
//     }
    
//     // Sort - Default: Latest first (1,2,3,4... order when no search/filter)
//     filtered.sort((a, b) {
//       int comparison;
      
//       if (filter.isActive) {
//         // When filters are active, sort by date
//         comparison = b.dateTime.compareTo(a.dateTime);
//       } else {
//         // When no filters, sort by chalan number (1,2,3,4...)
//         final aNum = int.tryParse(a.chalanNumber) ?? 0;
//         final bNum = int.tryParse(b.chalanNumber) ?? 0;
//         comparison = aNum.compareTo(bNum);
//       }
      
//       return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
//     });
    
//     return filtered;
//   }
  
//   void updateOriginalChalans(List<Chalan> chalans) {
//     add(UpdateOriginalChalans(chalans));
//   }
// }
