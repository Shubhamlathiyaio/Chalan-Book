import 'dart:async';
import 'package:chalan_book_app/features/filter/advanced_filter_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/chalan.dart';
import '../../../main.dart';
import 'advanced_filter_event.dart';
import 'advanced_filter_state.dart';

/// Advanced BLoC for comprehensive chalan filtering
class AdvancedChalanFilterBloc extends Bloc<AdvancedChalanFilterEvent, AdvancedChalanFilterState> {
  Timer? _debounceTimer;

  AdvancedChalanFilterBloc() : super(const AdvancedChalanFilterInitialState()) {
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<SetDateRangeFilterEvent>(_onSetDateRangeFilter);
    on<SetChalanNumberRangeFilterEvent>(_onSetChalanNumberRangeFilter);
    on<SetCreatedByFilterEvent>(_onSetCreatedByFilter);
    on<SetMonthFilterEvent>(_onSetMonthFilter);
    on<ChangeSortOrderEvent>(_onChangeSortOrder);
    on<ChangeSortByEvent>(_onChangeSortBy);
    on<ClearAllFiltersEvent>(_onClearAllFilters);
    on<ApplyFiltersEvent>(_onApplyFilters);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Handle search query with smart detection
  Future<void> _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    _debounceTimer?.cancel();

    final completer = Completer<void>();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!emit.isDone) {
        // Smart detection of search type
        final searchType = _detectSearchType(event.query);
        
        final updatedFilter = state.filter.copyWith(
          searchQuery: event.query,
          searchType: searchType,
        );
        
        await _applyFiltersInternal(updatedFilter, emit);
      }
      completer.complete();
    });

    await completer.future;
  }

  /// Detect search type based on input pattern
  SearchType _detectSearchType(String query) {
    // Check if query contains date separators
    if (query.contains('/') || query.contains('-')) {
      return SearchType.date;
    }
    
    // Check if query is purely numeric
    if (RegExp(r'^\d+$').hasMatch(query)) {
      return SearchType.chalanNumber;
    }
    
    // Default to chalan number search
    return SearchType.chalanNumber;
  }

  /// Handle date range filter
  Future<void> _onSetDateRangeFilter(
    SetDateRangeFilterEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle chalan number range filter
  Future<void> _onSetChalanNumberRangeFilter(
    SetChalanNumberRangeFilterEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      fromChalanNumber: event.fromNumber,
      toChalanNumber: event.toNumber,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle created by filter
  Future<void> _onSetCreatedByFilter(
    SetCreatedByFilterEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      createdByFilter: event.filter,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle month filter
  Future<void> _onSetMonthFilter(
    SetMonthFilterEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      selectedMonth: event.month,
      selectedYear: event.year,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle sort order change
  Future<void> _onChangeSortOrder(
    ChangeSortOrderEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      sortOrder: event.sortOrder,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle sort by change
  Future<void> _onChangeSortBy(
    ChangeSortByEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      sortBy: event.sortBy,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle clear all filters
  Future<void> _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    const clearedFilter = AdvancedChalanFilter();
    await _applyFiltersInternal(clearedFilter, emit);
  }

  /// Handle apply filters
  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;
    await _applyFiltersInternal(state.filter, emit);
  }

  /// Internal method to apply all filters and sorting
  Future<void> _applyFiltersInternal(
    AdvancedChalanFilter filter,
    Emitter<AdvancedChalanFilterState> emit,
  ) async {
    if (emit.isDone) return;

    try {
      if (!emit.isDone) {
        emit(AdvancedChalanFilterLoadingState(
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: state.filteredChalans,
        ));
      }

      List<Chalan> filtered = List.from(state.originalChalans);

      // Apply search filter
      if (filter.searchQuery.isNotEmpty) {
        filtered = _applySearchFilter(filtered, filter);
      }

      // Apply date range filter
      if (filter.fromDate != null || filter.toDate != null) {
        filtered = _applyDateRangeFilter(filtered, filter);
      }

      // Apply chalan number range filter
      if (filter.fromChalanNumber != null || filter.toChalanNumber != null) {
        filtered = _applyChalanNumberRangeFilter(filtered, filter);
      }

      // Apply created by filter
      if (filter.createdByFilter != CreatedByFilter.all) {
        filtered = _applyCreatedByFilter(filtered, filter);
      }

      // Apply month filter
      if (filter.selectedMonth != null) {
        filtered = _applyMonthFilter(filtered, filter);
      }

      // Apply sorting
      filtered = _applySorting(filtered, filter);

      if (!emit.isDone) {
        emit(AdvancedChalanFilterAppliedState(
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: filtered,
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(AdvancedChalanFilterErrorState(
          message: 'Error applying filters: $e',
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: state.filteredChalans,
        ));
      }
    }
  }

  /// Apply search filter based on detected type
  List<Chalan> _applySearchFilter(List<Chalan> chalans, AdvancedChalanFilter filter) {
    final query = filter.searchQuery.toLowerCase();

    return chalans.where((chalan) {
      switch (filter.searchType) {
        case SearchType.chalanNumber:
          return chalan.chalanNumber.toLowerCase().contains(query);
        
        case SearchType.date:
          // Parse different date formats
          final dateStr1 = '${chalan.dateTime.day}/${chalan.dateTime.month}/${chalan.dateTime.year}';
          final dateStr2 = '${chalan.dateTime.day}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.year}';
          final dateStr3 = '${chalan.dateTime.year}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.day.toString().padLeft(2, '0')}';
          
          return dateStr1.contains(query) || 
                 dateStr2.contains(query) || 
                 dateStr3.contains(query);
      }
    }).toList();
  }

  /// Apply date range filter
  List<Chalan> _applyDateRangeFilter(List<Chalan> chalans, AdvancedChalanFilter filter) {
    return chalans.where((chalan) {
      final chalanDate = chalan.dateTime;
      
      // If only fromDate is set, filter dates after it
      if (filter.fromDate != null && filter.toDate == null) {
        return chalanDate.isAfter(filter.fromDate!) || 
               chalanDate.isAtSameMomentAs(filter.fromDate!);
      }
      
      // If only toDate is set, filter dates before it
      if (filter.fromDate == null && filter.toDate != null) {
        return chalanDate.isBefore(filter.toDate!) || 
               chalanDate.isAtSameMomentAs(filter.toDate!);
      }
      
      // If both are set, filter between range
      if (filter.fromDate != null && filter.toDate != null) {
        return (chalanDate.isAfter(filter.fromDate!) || chalanDate.isAtSameMomentAs(filter.fromDate!)) &&
               (chalanDate.isBefore(filter.toDate!) || chalanDate.isAtSameMomentAs(filter.toDate!));
      }
      
      return true;
    }).toList();
  }

  /// Apply chalan number range filter
  List<Chalan> _applyChalanNumberRangeFilter(List<Chalan> chalans, AdvancedChalanFilter filter) {
    return chalans.where((chalan) {
      final chalanNum = int.tryParse(chalan.chalanNumber) ?? 0;
      
      // If only fromNumber is set, filter numbers above it
      if (filter.fromChalanNumber != null && filter.toChalanNumber == null) {
        return chalanNum >= filter.fromChalanNumber!;
      }
      
      // If only toNumber is set, filter numbers below it
      if (filter.fromChalanNumber == null && filter.toChalanNumber != null) {
        return chalanNum <= filter.toChalanNumber!;
      }
      
      // If both are set, filter between range
      if (filter.fromChalanNumber != null && filter.toChalanNumber != null) {
        return chalanNum >= filter.fromChalanNumber! && chalanNum <= filter.toChalanNumber!;
      }
      
      return true;
    }).toList();
  }

  /// Apply created by filter
  List<Chalan> _applyCreatedByFilter(List<Chalan> chalans, AdvancedChalanFilter filter) {
    final currentUserId = supabase.auth.currentUser?.id;
    
    return chalans.where((chalan) {
      switch (filter.createdByFilter) {
        case CreatedByFilter.all:
          return true;
        case CreatedByFilter.me:
          return chalan.createdBy == currentUserId;
        case CreatedByFilter.owner:
          // You'll need to implement logic to check if creator is owner
          return true; // Placeholder
        case CreatedByFilter.member:
          // You'll need to implement logic to check if creator is member
          return chalan.createdBy != currentUserId; // Placeholder
      }
    }).toList();
  }

  /// Apply month filter
  List<Chalan> _applyMonthFilter(List<Chalan> chalans, AdvancedChalanFilter filter) {
    return chalans.where((chalan) {
      final chalanDate = chalan.dateTime;
      
      bool monthMatch = filter.selectedMonth == null || chalanDate.month == filter.selectedMonth;
      bool yearMatch = filter.selectedYear == null || chalanDate.year == filter.selectedYear;
      
      return monthMatch && yearMatch;
    }).toList();
  }

  /// Apply sorting
  List<Chalan> _applySorting(List<Chalan> chalans, AdvancedChalanFilter filter) {
    chalans.sort((a, b) {
      int comparison = 0;
      
      switch (filter.sortBy) {
        case SortBy.createdAt:
          comparison = a.dateTime.compareTo(b.dateTime);
          break;
        case SortBy.chalanNumber:
          final aNum = int.tryParse(a.chalanNumber) ?? 0;
          final bNum = int.tryParse(b.chalanNumber) ?? 0;
          comparison = aNum.compareTo(bNum);
          break;
        case SortBy.dateTime:
          comparison = a.dateTime.compareTo(b.dateTime);
          break;
      }
      
      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    return chalans;
  }

  /// Update original chalans list
  void updateOriginalChalans(List<Chalan> chalans) {
    if (isClosed) return;

    final newState = AdvancedChalanFilterAppliedState(
      filter: state.filter,
      originalChalans: chalans,
      filteredChalans: chalans,
    );

    emit(newState);
    add(ApplyFiltersEvent());
  }
}
