import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/chalan.dart';
import '../../../main.dart';
import '../models/advanced_filter_model.dart';
import 'filter_event.dart';
import 'filter_state.dart';

/// BLoC for filtering chalans locally
class FilterBloc extends Bloc<FilterEvent, FilterState> {
  Timer? _debounceTimer;

  FilterBloc() : super(const FilterInitialState()) {
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

  Future<void> _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<FilterState> emit,
  ) async {
    _debounceTimer?.cancel();

    final completer = Completer<void>();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!emit.isDone) {
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

  SearchType _detectSearchType(String query) {
    if (query.contains('/') || query.contains('-')) return SearchType.date;
    if (RegExp(r'^\d+$').hasMatch(query)) return SearchType.chalanNumber;
    return SearchType.chalanNumber;
  }

  Future<void> _onSetDateRangeFilter(
    SetDateRangeFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    final updatedFilter = state.filter.copyWith(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    await _applyFiltersInternal(updatedFilter, emit);
  }

  Future<void> _onSetChalanNumberRangeFilter(
    SetChalanNumberRangeFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    final updatedFilter = state.filter.copyWith(
      fromChalanNumber: event.fromNumber,
      toChalanNumber: event.toNumber,
    );
    await _applyFiltersInternal(updatedFilter, emit);
  }

  Future<void> _onSetCreatedByFilter(
    SetCreatedByFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    final updatedFilter = state.filter.copyWith(createdByFilter: event.filter);
    await _applyFiltersInternal(updatedFilter, emit);
  }

  Future<void> _onSetMonthFilter(
    SetMonthFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    final updatedFilter = state.filter.copyWith(
      selectedMonth: event.month,
      selectedYear: event.year,
    );
    await _applyFiltersInternal(updatedFilter, emit);
  }

  Future<void> _onChangeSortOrder(
    ChangeSortOrderEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    final updatedFilter = state.filter.copyWith(sortOrder: event.sortOrder);
    await _applyFiltersInternal(updatedFilter, emit);
  }

  Future<void> _onChangeSortBy(
    ChangeSortByEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    final updatedFilter = state.filter.copyWith(sortBy: event.sortBy);
    await _applyFiltersInternal(updatedFilter, emit);
  }

  Future<void> _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    const clearedFilter = AdvancedChalanFilter();
    await _applyFiltersInternal(clearedFilter, emit);
  }

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;
    await _applyFiltersInternal(state.filter, emit);
  }

  Future<void> _applyFiltersInternal(
    AdvancedChalanFilter filter,
    Emitter<FilterState> emit,
  ) async {
    if (emit.isDone) return;

    try {
      emit(
        FilterLoadingState(
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: state.filteredChalans,
        ),
      );

      List<Chalan> filtered = List.from(state.originalChalans);

      if (filter.searchQuery.isNotEmpty) {
        filtered = _applySearchFilter(filtered, filter);
      }

      if (filter.fromDate != null || filter.toDate != null) {
        filtered = _applyDateRangeFilter(filtered, filter);
      }

      if (filter.fromChalanNumber != null || filter.toChalanNumber != null) {
        filtered = _applyChalanNumberRangeFilter(filtered, filter);
      }

      if (filter.createdByFilter != CreatedByFilter.all) {
        filtered = _applyCreatedByFilter(filtered, filter);
      }

      if (filter.selectedMonth != null) {
        filtered = _applyMonthFilter(filtered, filter);
      }

      filtered = _applySorting(filtered, filter);

      emit(
        FilterAppliedState(
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: filtered,
        ),
      );
    } catch (e) {
      emit(
        FilterErrorState(
          message: 'Error applying filters: $e',
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: state.filteredChalans,
        ),
      );
    }
  }

  List<Chalan> _applySearchFilter(
    List<Chalan> chalans,
    AdvancedChalanFilter filter,
  ) {
    final query = filter.searchQuery.toLowerCase();

    return chalans.where((chalan) {
      switch (filter.searchType) {
        case SearchType.chalanNumber:
          return chalan.chalanNumber.toLowerCase().contains(query);
        case SearchType.date:
          final dateStr1 =
              '${chalan.dateTime.day}/${chalan.dateTime.month}/${chalan.dateTime.year}';
          final dateStr2 =
              '${chalan.dateTime.day}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.year}';
          final dateStr3 =
              '${chalan.dateTime.year}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.day.toString().padLeft(2, '0')}';
          return dateStr1.contains(query) ||
              dateStr2.contains(query) ||
              dateStr3.contains(query);
      }
    }).toList();
  }

  List<Chalan> _applyDateRangeFilter(
    List<Chalan> chalans,
    AdvancedChalanFilter filter,
  ) {
    return chalans.where((chalan) {
      final date = chalan.dateTime;
      if (filter.fromDate != null && filter.toDate == null) {
        return date.isAfter(filter.fromDate!) ||
            date.isAtSameMomentAs(filter.fromDate!);
      }
      if (filter.fromDate == null && filter.toDate != null) {
        return date.isBefore(filter.toDate!) ||
            date.isAtSameMomentAs(filter.toDate!);
      }
      if (filter.fromDate != null && filter.toDate != null) {
        return (date.isAfter(filter.fromDate!) ||
                date.isAtSameMomentAs(filter.fromDate!)) &&
            (date.isBefore(filter.toDate!) ||
                date.isAtSameMomentAs(filter.toDate!));
      }
      return true;
    }).toList();
  }

  List<Chalan> _applyChalanNumberRangeFilter(
    List<Chalan> chalans,
    AdvancedChalanFilter filter,
  ) {
    return chalans.where((chalan) {
      final num = int.tryParse(chalan.chalanNumber) ?? 0;
      if (filter.fromChalanNumber != null && filter.toChalanNumber == null) {
        return num >= filter.fromChalanNumber!;
      }
      if (filter.fromChalanNumber == null && filter.toChalanNumber != null) {
        return num <= filter.toChalanNumber!;
      }
      if (filter.fromChalanNumber != null && filter.toChalanNumber != null) {
        return num >= filter.fromChalanNumber! && num <= filter.toChalanNumber!;
      }
      return true;
    }).toList();
  }

  List<Chalan> _applyCreatedByFilter(
    List<Chalan> chalans,
    AdvancedChalanFilter filter,
  ) {
    final userId = supabase.auth.currentUser?.id;

    return chalans.where((chalan) {
      switch (filter.createdByFilter) {
        case CreatedByFilter.all:
          return true;
        case CreatedByFilter.me:
          return chalan.createdBy == userId;
        case CreatedByFilter.owner:
          return true; // 🛠️ Customize later
        case CreatedByFilter.member:
          return chalan.createdBy != userId; // 🛠️ Customize later
      }
    }).toList();
  }

  List<Chalan> _applyMonthFilter(
    List<Chalan> chalans,
    AdvancedChalanFilter filter,
  ) {
    return chalans.where((chalan) {
      final date = chalan.dateTime;
      bool monthMatch =
          filter.selectedMonth == null || date.month == filter.selectedMonth;
      bool yearMatch =
          filter.selectedYear == null || date.year == filter.selectedYear;
      return monthMatch && yearMatch;
    }).toList();
  }

  List<Chalan> _applySorting(
    List<Chalan> chalans,
    AdvancedChalanFilter filter,
  ) {
    chalans.sort((a, b) {
      int compare = 0;
      switch (filter.sortBy) {
        case SortBy.createdAt:
          compare = a.dateTime.compareTo(b.dateTime);
          break;
        case SortBy.chalanNumber:
          final aNum = int.tryParse(a.chalanNumber) ?? 0;
          final bNum = int.tryParse(b.chalanNumber) ?? 0;
          compare = aNum.compareTo(bNum);
          break;
        case SortBy.dateTime:
          compare = a.dateTime.compareTo(b.dateTime);
          break;
      }
      return filter.sortOrder == SortOrder.ascending ? compare : -compare;
    });
    return chalans;
  }

  void updateOriginalChalans(List<Chalan> chalans) {
    if (isClosed) return;
    final stateToEmit = FilterAppliedState(
      filter: state.filter,
      originalChalans: chalans,
      filteredChalans: chalans,
    );
    emit(stateToEmit);
    add(ApplyFiltersEvent());
  }
}
