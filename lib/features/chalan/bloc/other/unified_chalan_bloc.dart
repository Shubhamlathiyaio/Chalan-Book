// import 'dart:async';
// import 'package:chalan_book_app/features/chalan/models/unified_chalan_filter.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/constants/app_keys.dart';
// import '../../../../core/models/chalan.dart';
// import '../../../../main.dart';
// import '../../../organization/bloc/organization_bloc.dart';

// // Events
// abstract class UnifiedChalanEvent {}

// // Chalan CRUD Events
// class LoadChalansEvent extends UnifiedChalanEvent {
//   final String organizationId;
//   LoadChalansEvent(this.organizationId);
// }

// class AddChalanEvent extends UnifiedChalanEvent {
//   final Chalan chalan;
//   AddChalanEvent(this.chalan);
// }

// class UpdateChalanEvent extends UnifiedChalanEvent {
//   final Chalan chalan;
//   UpdateChalanEvent(this.chalan);
// }

// class DeleteChalanEvent extends UnifiedChalanEvent {
//   final Chalan chalan;
//   DeleteChalanEvent(this.chalan);
// }

// class RefreshChalansEvent extends UnifiedChalanEvent {
//   final String organizationId;
//   RefreshChalansEvent(this.organizationId);
// }

// // Filter Events
// class UpdateSearchQueryEvent extends UnifiedChalanEvent {
//   final String query;
//   UpdateSearchQueryEvent(this.query);
// }

// class SetDateRangeFilterEvent extends UnifiedChalanEvent {
//   final DateTime? fromDate;
//   final DateTime? toDate;
//   SetDateRangeFilterEvent({this.fromDate, this.toDate});
// }

// class SetChalanNumberRangeFilterEvent extends UnifiedChalanEvent {
//   final int? fromNumber;
//   final int? toNumber;
//   SetChalanNumberRangeFilterEvent({this.fromNumber, this.toNumber});
// }

// class SetCreatedByFilterEvent extends UnifiedChalanEvent {
//   final CreatedByFilter filter;
//   SetCreatedByFilterEvent(this.filter);
// }

// class SetMonthFilterEvent extends UnifiedChalanEvent {
//   final int? month;
//   final int? year;
//   SetMonthFilterEvent({this.month, this.year});
// }

// class ChangeSortOrderEvent extends UnifiedChalanEvent {
//   final SortOrder sortOrder;
//   ChangeSortOrderEvent(this.sortOrder);
// }

// class ChangeSortByEvent extends UnifiedChalanEvent {
//   final SortBy sortBy;
//   ChangeSortByEvent(this.sortBy);
// }

// class ClearAllFiltersEvent extends UnifiedChalanEvent {}

// // Chalan Number Events
// class SelectChalanNumberEvent extends UnifiedChalanEvent {
//   final int selectedNumber;
//   SelectChalanNumberEvent(this.selectedNumber);
// }

// class ClearSelectedNumberEvent extends UnifiedChalanEvent {}

// // States
// abstract class UnifiedChalanState {}

// class UnifiedChalanInitial extends UnifiedChalanState {}

// class UnifiedChalanLoading extends UnifiedChalanState {}

// class UnifiedChalanLoaded extends UnifiedChalanState {
//   final List<Chalan> originalChalans;
//   final List<Chalan> filteredChalans;
//   final UnifiedChalanFilter filter;
//   final List<int> missingNumbers;
//   final int? selectedNumber;
//   final int nextAvailableNumber;

//   UnifiedChalanLoaded({
//     required this.originalChalans,
//     required this.filteredChalans,
//     required this.filter,
//     required this.missingNumbers,
//     this.selectedNumber,
//     required this.nextAvailableNumber,
//   });
// }

// class UnifiedChalanEmpty extends UnifiedChalanState {}

// class UnifiedChalanError extends UnifiedChalanState {
//   final String message;
//   UnifiedChalanError(this.message);
// }

// class UnifiedChalanOperationSuccess extends UnifiedChalanState {
//   final String message;
//   final List<Chalan> originalChalans;
//   final List<Chalan> filteredChalans;
//   final UnifiedChalanFilter filter;
//   final List<int> missingNumbers;
//   final int? selectedNumber;
//   final int nextAvailableNumber;

//   UnifiedChalanOperationSuccess({
//     required this.message,
//     required this.originalChalans,
//     required this.filteredChalans,
//     required this.filter,
//     required this.missingNumbers,
//     this.selectedNumber,
//     required this.nextAvailableNumber,
//   });
// }

// // BLoC
// class UnifiedChalanBloc extends Bloc<UnifiedChalanEvent, UnifiedChalanState> {
//   final OrganizationBloc organizationBloc;
//   StreamSubscription? _organizationSubscription;
//   Timer? _debounceTimer;

//   UnifiedChalanBloc({required this.organizationBloc}) : super(UnifiedChalanInitial()) {
//     // CRUD Events
//     on<LoadChalansEvent>(_onLoadChalans);
//     on<AddChalanEvent>(_onAddChalan);
//     on<UpdateChalanEvent>(_onUpdateChalan);
//     on<DeleteChalanEvent>(_onDeleteChalan);
//     on<RefreshChalansEvent>(_onRefreshChalans);
    
//     // Filter Events
//     on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
//     on<SetDateRangeFilterEvent>(_onSetDateRangeFilter);
//     on<SetChalanNumberRangeFilterEvent>(_onSetChalanNumberRangeFilter);
//     on<SetCreatedByFilterEvent>(_onSetCreatedByFilter);
//     on<SetMonthFilterEvent>(_onSetMonthFilter);
//     on<ChangeSortOrderEvent>(_onChangeSortOrder);
//     on<ChangeSortByEvent>(_onChangeSortBy);
//     on<ClearAllFiltersEvent>(_onClearAllFilters);
    
//     // Number Events
//     on<SelectChalanNumberEvent>(_onSelectChalanNumber);
//     on<ClearSelectedNumberEvent>(_onClearSelectedNumber);
    
//     _initializeOrganizationListener();
//   }

//   void _initializeOrganizationListener() {
//     _organizationSubscription = organizationBloc.stream.listen((orgState) {
//       if (orgState is OrganizationLoaded && orgState.currentOrg != null) {
//         add(LoadChalansEvent(orgState.currentOrg!.id));
//       }
//     });

//     if (organizationBloc.state is OrganizationLoaded) {
//       final state = organizationBloc.state as OrganizationLoaded;
//       if (state.currentOrg != null) {
//         add(LoadChalansEvent(state.currentOrg!.id));
//       }
//     }
//   }

//   @override
//   Future<void> close() {
//     _organizationSubscription?.cancel();
//     _debounceTimer?.cancel();
//     return super.close();
//   }

//   // CRUD Event Handlers
//   Future<void> _onLoadChalans(LoadChalansEvent event, Emitter<UnifiedChalanState> emit) async {
//     emit(UnifiedChalanLoading());
    
//     try {
//       final response = await supabase
//           .from(chalansTable)
//           .select()
//           .eq('organization_id', event.organizationId)
//           .order('chalan_number', ascending: true);

//       final chalans = response.map((e) => Chalan.fromJson(e)).toList();
      
//       if (chalans.isEmpty) {
//         emit(UnifiedChalanEmpty());
//       } else {
//         final filter = const UnifiedChalanFilter();
//         final filteredChalans = _applyFilters(chalans, filter);
//         final numberData = _calculateMissingNumbers(chalans);
        
//         emit(UnifiedChalanLoaded(
//           originalChalans: chalans,
//           filteredChalans: filteredChalans,
//           filter: filter,
//           missingNumbers: numberData['missing'],
//           nextAvailableNumber: numberData['next'],
//         ));
//       }
//     } catch (e) {
//       emit(UnifiedChalanError('Error loading chalans: $e'));
//     }
//   }

//   Future<void> _onAddChalan(AddChalanEvent event, Emitter<UnifiedChalanState> emit) async {
//     try {
//       await supabase.from(chalansTable).insert(event.chalan.toJson());
      
//       if (state is UnifiedChalanLoaded) {
//         final currentState = state as UnifiedChalanLoaded;
//         final updatedChalans = List<Chalan>.from(currentState.originalChalans);
//         updatedChalans.add(event.chalan);
        
//         // Sort to maintain order
//         updatedChalans.sort((a, b) {
//           final aNum = int.tryParse(a.chalanNumber) ?? 0;
//           final bNum = int.tryParse(b.chalanNumber) ?? 0;
//           return aNum.compareTo(bNum);
//         });
        
//         final filteredChalans = _applyFilters(updatedChalans, currentState.filter);
//         final numberData = _calculateMissingNumbers(updatedChalans);
        
//         emit(UnifiedChalanOperationSuccess(
//           message: 'Chalan added successfully!',
//           originalChalans: updatedChalans,
//           filteredChalans: filteredChalans,
//           filter: currentState.filter,
//           missingNumbers: numberData['missing'],
//           nextAvailableNumber: numberData['next'],
//         ));
//       }
//     } catch (e) {
//       emit(UnifiedChalanError('Error adding chalan: $e'));
//     }
//   }

//   Future<void> _onUpdateChalan(UpdateChalanEvent event, Emitter<UnifiedChalanState> emit) async {
//     try {
//       await supabase
//           .from(chalansTable)
//           .update(event.chalan.toJson())
//           .eq('id', event.chalan.id);
      
//       if (state is UnifiedChalanLoaded) {
//         final currentState = state as UnifiedChalanLoaded;
//         final updatedChalans = List<Chalan>.from(currentState.originalChalans);
//         final index = updatedChalans.indexWhere((c) => c.id == event.chalan.id);
        
//         if (index != -1) {
//           updatedChalans[index] = event.chalan;
//           final filteredChalans = _applyFilters(updatedChalans, currentState.filter);
//           final numberData = _calculateMissingNumbers(updatedChalans);
          
//           emit(UnifiedChalanOperationSuccess(
//             message: 'Chalan updated successfully!',
//             originalChalans: updatedChalans,
//             filteredChalans: filteredChalans,
//             filter: currentState.filter,
//             missingNumbers: numberData['missing'],
//             nextAvailableNumber: numberData['next'],
//           ));
//         }
//       }
//     } catch (e) {
//       emit(UnifiedChalanError('Error updating chalan: $e'));
//     }
//   }

//   Future<void> _onDeleteChalan(DeleteChalanEvent event, Emitter<UnifiedChalanState> emit) async {
//     try {
//       if (event.chalan.imageUrl != null) {
//         final uri = Uri.parse(event.chalan.imageUrl!);
//         final fileName = uri.pathSegments.last;
//         await supabase.storage.from(chalanImagesBucket).remove([fileName]);
//       }

//       await supabase.from(chalansTable).delete().eq('id', event.chalan.id);
      
//       if (state is UnifiedChalanLoaded) {
//         final currentState = state as UnifiedChalanLoaded;
//         final updatedChalans = List<Chalan>.from(currentState.originalChalans);
//         updatedChalans.removeWhere((c) => c.id == event.chalan.id);
        
//         if (updatedChalans.isEmpty) {
//           emit(UnifiedChalanEmpty());
//         } else {
//           final filteredChalans = _applyFilters(updatedChalans, currentState.filter);
//           final numberData = _calculateMissingNumbers(updatedChalans);
          
//           emit(UnifiedChalanOperationSuccess(
//             message: 'Chalan deleted successfully!',
//             originalChalans: updatedChalans,
//             filteredChalans: filteredChalans,
//             filter: currentState.filter,
//             missingNumbers: numberData['missing'],
//             nextAvailableNumber: numberData['next'],
//           ));
//         }
//       }
//     } catch (e) {
//       emit(UnifiedChalanError('Error deleting chalan: $e'));
//     }
//   }

//   Future<void> _onRefreshChalans(RefreshChalansEvent event, Emitter<UnifiedChalanState> emit) async {
//     add(LoadChalansEvent(event.organizationId));
//   }

//   // Filter Event Handlers
//   void _onUpdateSearchQuery(UpdateSearchQueryEvent event, Emitter<UnifiedChalanState> emit) {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       if (!isClosed && state is UnifiedChalanLoaded) {
//         final currentState = state as UnifiedChalanLoaded;
//         final searchType = _detectSearchType(event.query);
        
//         final updatedFilter = currentState.filter.copyWith(
//           searchQuery: event.query,
//           searchType: searchType,
//         );
        
//         final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
        
//         emit(UnifiedChalanLoaded(
//           originalChalans: currentState.originalChalans,
//           filteredChalans: filteredChalans,
//           filter: updatedFilter,
//           missingNumbers: currentState.missingNumbers,
//           selectedNumber: currentState.selectedNumber,
//           nextAvailableNumber: currentState.nextAvailableNumber,
//         ));
//       }
//     });
//   }

//   void _onSetDateRangeFilter(SetDateRangeFilterEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       final updatedFilter = currentState.filter.copyWith(
//         fromDate: event.fromDate,
//         toDate: event.toDate,
//       );
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: updatedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onSetChalanNumberRangeFilter(SetChalanNumberRangeFilterEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       final updatedFilter = currentState.filter.copyWith(
//         fromChalanNumber: event.fromNumber,
//         toChalanNumber: event.toNumber,
//       );
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: updatedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onSetCreatedByFilter(SetCreatedByFilterEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       final updatedFilter = currentState.filter.copyWith(
//         createdByFilter: event.filter,
//       );
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: updatedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onSetMonthFilter(SetMonthFilterEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       final updatedFilter = currentState.filter.copyWith(
//         selectedMonth: event.month,
//         selectedYear: event.year,
//       );
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: updatedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onChangeSortOrder(ChangeSortOrderEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       final updatedFilter = currentState.filter.copyWith(
//         sortOrder: event.sortOrder,
//       );
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: updatedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onChangeSortBy(ChangeSortByEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       final updatedFilter = currentState.filter.copyWith(
//         sortBy: event.sortBy,
//       );
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, updatedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: updatedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onClearAllFilters(ClearAllFiltersEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
//       const clearedFilter = UnifiedChalanFilter();
      
//       final filteredChalans = _applyFilters(currentState.originalChalans, clearedFilter);
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: filteredChalans,
//         filter: clearedFilter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: currentState.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   // Number Event Handlers
//   void _onSelectChalanNumber(SelectChalanNumberEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: currentState.filteredChalans,
//         filter: currentState.filter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: event.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onClearSelectedNumber(ClearSelectedNumberEvent event, Emitter<UnifiedChalanState> emit) {
//     if (state is UnifiedChalanLoaded) {
//       final currentState = state as UnifiedChalanLoaded;
      
//       emit(UnifiedChalanLoaded(
//         originalChalans: currentState.originalChalans,
//         filteredChalans: currentState.filteredChalans,
//         filter: currentState.filter,
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: null,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   // Helper Methods
//   SearchType _detectSearchType(String query) {
//     if (query.contains('/') || query.contains('-')) {
//       return SearchType.date;
//     }
//     if (RegExp(r'^\d+$').hasMatch(query)) {
//       return SearchType.chalanNumber;
//     }
//     return SearchType.chalanNumber;
//   }

//   List<Chalan> _applyFilters(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     List<Chalan> filtered = List.from(chalans);
    
//     // Apply search filter
//     if (filter.searchQuery.isNotEmpty) {
//       filtered = _applySearchFilter(filtered, filter);
//     }
    
//     // Apply date range filter
//     if (filter.fromDate != null || filter.toDate != null) {
//       filtered = _applyDateRangeFilter(filtered, filter);
//     }
    
//     // Apply chalan number range filter
//     if (filter.fromChalanNumber != null || filter.toChalanNumber != null) {
//       filtered = _applyChalanNumberRangeFilter(filtered, filter);
//     }
    
//     // Apply created by filter
//     if (filter.createdByFilter != CreatedByFilter.all) {
//       filtered = _applyCreatedByFilter(filtered, filter);
//     }
    
//     // Apply month filter
//     if (filter.selectedMonth != null) {
//       filtered = _applyMonthFilter(filtered, filter);
//     }
    
//     // Apply sorting
//     filtered = _applySorting(filtered, filter);
    
//     return filtered;
//   }

//   List<Chalan> _applySearchFilter(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     final query = filter.searchQuery.toLowerCase();
    
//     return chalans.where((chalan) {
//       switch (filter.searchType) {
//         case SearchType.chalanNumber:
//           return chalan.chalanNumber.toLowerCase().contains(query);
//         case SearchType.date:
//           final dateStr1 = '${chalan.dateTime.day}/${chalan.dateTime.month}/${chalan.dateTime.year}';
//           final dateStr2 = '${chalan.dateTime.day}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.year}';
//           final dateStr3 = '${chalan.dateTime.year}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.day.toString().padLeft(2, '0')}';
//           return dateStr1.contains(query) || dateStr2.contains(query) || dateStr3.contains(query);
//       }
//     }).toList();
//   }

//   List<Chalan> _applyDateRangeFilter(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     return chalans.where((chalan) {
//       final chalanDate = chalan.dateTime;
      
//       if (filter.fromDate != null && filter.toDate == null) {
//         return chalanDate.isAfter(filter.fromDate!) || chalanDate.isAtSameMomentAs(filter.fromDate!);
//       }
      
//       if (filter.fromDate == null && filter.toDate != null) {
//         return chalanDate.isBefore(filter.toDate!) || chalanDate.isAtSameMomentAs(filter.toDate!);
//       }
      
//       if (filter.fromDate != null && filter.toDate != null) {
//         return (chalanDate.isAfter(filter.fromDate!) || chalanDate.isAtSameMomentAs(filter.fromDate!)) &&
//                (chalanDate.isBefore(filter.toDate!) || chalanDate.isAtSameMomentAs(filter.toDate!));
//       }
      
//       return true;
//     }).toList();
//   }

//   List<Chalan> _applyChalanNumberRangeFilter(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     return chalans.where((chalan) {
//       final chalanNum = int.tryParse(chalan.chalanNumber) ?? 0;
      
//       if (filter.fromChalanNumber != null && filter.toChalanNumber == null) {
//         return chalanNum >= filter.fromChalanNumber!;
//       }
      
//       if (filter.fromChalanNumber == null && filter.toChalanNumber != null) {
//         return chalanNum <= filter.toChalanNumber!;
//       }
      
//       if (filter.fromChalanNumber != null && filter.toChalanNumber != null) {
//         return chalanNum >= filter.fromChalanNumber! && chalanNum <= filter.toChalanNumber!;
//       }
      
//       return true;
//     }).toList();
//   }

//   List<Chalan> _applyCreatedByFilter(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     final currentUserId = supabase.auth.currentUser?.id;
    
//     return chalans.where((chalan) {
//       switch (filter.createdByFilter) {
//         case CreatedByFilter.all:
//           return true;
//         case CreatedByFilter.me:
//           return chalan.createdBy == currentUserId;
//         case CreatedByFilter.owner:
//           return true; // Implement owner logic
//         case CreatedByFilter.member:
//           return chalan.createdBy != currentUserId;
//       }
//     }).toList();
//   }

//   List<Chalan> _applyMonthFilter(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     return chalans.where((chalan) {
//       final chalanDate = chalan.dateTime;
      
//       bool monthMatch = filter.selectedMonth == null || chalanDate.month == filter.selectedMonth;
//       bool yearMatch = filter.selectedYear == null || chalanDate.year == filter.selectedYear;
      
//       return monthMatch && yearMatch;
//     }).toList();
//   }

//   List<Chalan> _applySorting(List<Chalan> chalans, UnifiedChalanFilter filter) {
//     chalans.sort((a, b) {
//       int comparison = 0;
      
//       switch (filter.sortBy) {
//         case SortBy.createdAt:
//           comparison = a.dateTime.compareTo(b.dateTime);
//           break;
//         case SortBy.chalanNumber:
//           final aNum = int.tryParse(a.chalanNumber) ?? 0;
//           final bNum = int.tryParse(b.chalanNumber) ?? 0;
//           comparison = aNum.compareTo(bNum);
//           break;
//         case SortBy.dateTime:
//           comparison = a.dateTime.compareTo(b.dateTime);
//           break;
//       }
      
//       return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
//     });
    
//     return chalans;
//   }

//   Map<String, dynamic> _calculateMissingNumbers(List<Chalan> chalans) {
//     final existingNumbers = chalans
//         .map((chalan) => int.tryParse(chalan.chalanNumber) ?? 0)
//         .where((num) => num > 0)
//         .toSet();

//     if (existingNumbers.isEmpty) {
//       return {
//         'missing': <int>[],
//         'next': 1,
//       };
//     }

//     final maxNumber = existingNumbers.reduce((a, b) => a > b ? a : b);
//     final missingNumbers = <int>[];

//     // Find missing numbers from 1 to maxNumber
//     for (int i = 1; i <= maxNumber; i++) {
//       if (!existingNumbers.contains(i)) {
//         missingNumbers.add(i);
//       }
//     }

//     // Next available number is either the first missing number or maxNumber + 1
//     final nextAvailable = missingNumbers.isNotEmpty 
//         ? missingNumbers.first 
//         : maxNumber + 1;

//     return {
//       'missing': missingNumbers,
//       'next': nextAvailable,
//     };
//   }
// }
