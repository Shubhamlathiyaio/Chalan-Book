import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/chalan.dart';
import '../../../main.dart';
import '../../features/filter/filter_model.dart';
import 'filter_event.dart';
import 'filter_state.dart';

/// BLoC to handle chalan filtering logic
class ChalanFilterBloc extends Bloc<ChalanFilterEvent, ChalanFilterState> {
  Timer? _debounceTimer;

  ChalanFilterBloc() : super(const ChalanFilterInitialState()) {
    // Register event handlers
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<ChangeFilterTypeEvent>(_onChangeFilterType);
    on<SetCreatedByFilterEvent>(_onSetCreatedByFilter);
    on<SetChalanNumberRangeEvent>(_onSetChalanNumberRange);
    on<ClearAllFiltersEvent>(_onClearAllFilters);
    on<ApplyFiltersEvent>(_onApplyFilters);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Handle search query update with debounce
  Future<void> _onUpdateSearchQuery(
      UpdateSearchQueryEvent event,
      Emitter<ChalanFilterState> emit,
      ) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debounce (500ms delay)
    final completer = Completer<void>();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!emit.isDone) {
        final updatedFilter = state.filter.copyWith(searchQuery: event.query);
        await _applyFiltersInternal(updatedFilter, emit);
      }
      completer.complete();
    });

    // Wait for the timer to complete
    await completer.future;
  }

  /// Handle filter type change
  Future<void> _onChangeFilterType(
      ChangeFilterTypeEvent event,
      Emitter<ChalanFilterState> emit,
      ) async {
    if (emit.isDone) return;

    ChalanFilter updatedFilter;

    switch (event.filterType) {
      case FilterType.thisYear:
        updatedFilter = state.filter.copyWith(
          filterType: event.filterType,
          clearDate: true,
          clearCreatedBy: true,
        );
        break;
      case FilterType.allYears:
        updatedFilter = state.filter.copyWith(
          filterType: event.filterType,
          clearDate: true,
          clearCreatedBy: true,
        );
        break;
      case FilterType.byMonth:
        updatedFilter = state.filter.copyWith(
          filterType: event.filterType,
          specificMonth: event.month,
          specificYear: event.year,
          clearDate: true,
          clearCreatedBy: true,
        );
        break;
      case FilterType.byDate:
        updatedFilter = state.filter.copyWith(
          filterType: event.filterType,
          specificDate: event.date,
          clearCreatedBy: true,
        );
        break;
      case FilterType.createdByMe:
        updatedFilter = state.filter.copyWith(
          filterType: event.filterType,
          createdByUserId: supabase.auth.currentUser?.id,
          clearDate: true,
        );
        break;
      case FilterType.chalanNumberRange:
        updatedFilter = state.filter.copyWith(
          filterType: event.filterType,
          clearDate: true,
          clearCreatedBy: true,
        );
        break;
    }

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle created by filter
  Future<void> _onSetCreatedByFilter(
      SetCreatedByFilterEvent event,
      Emitter<ChalanFilterState> emit,
      ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      createdByUserId: event.userId,
      filterType: event.userId != null ? FilterType.createdByMe : FilterType.thisYear,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle chalan number range filter
  Future<void> _onSetChalanNumberRange(
      SetChalanNumberRangeEvent event,
      Emitter<ChalanFilterState> emit,
      ) async {
    if (emit.isDone) return;

    final updatedFilter = state.filter.copyWith(
      chalanNumberRange: event.range,
      customMinNumber: event.customMin,
      customMaxNumber: event.customMax,
    );

    await _applyFiltersInternal(updatedFilter, emit);
  }

  /// Handle clear all filters
  Future<void> _onClearAllFilters(
      ClearAllFiltersEvent event,
      Emitter<ChalanFilterState> emit,
      ) async {
    if (emit.isDone) return;

    const clearedFilter = ChalanFilter();
    await _applyFiltersInternal(clearedFilter, emit);
  }

  /// Handle apply filters
  Future<void> _onApplyFilters(
      ApplyFiltersEvent event,
      Emitter<ChalanFilterState> emit,
      ) async {
    if (emit.isDone) return;

    await _applyFiltersInternal(state.filter, emit);
  }

  /// Internal method to apply filters
  Future<void> _applyFiltersInternal(
      ChalanFilter filter,
      Emitter<ChalanFilterState> emit,
      ) async {
    if (emit.isDone) return;

    try {
      // Emit loading state
      if (!emit.isDone) {
        emit(ChalanFilterLoadingState(
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: state.filteredChalans,
        ));
      }

      // Apply all filters
      List<Chalan> filtered = List.from(state.originalChalans);

      // 1. Apply search filter (chalan number or date)
      if (filter.searchQuery.isNotEmpty) {
        filtered = _applySearchFilter(filtered, filter.searchQuery);
      }

      // 2. Apply date/time filters
      filtered = _applyDateFilter(filtered, filter);

      // 3. Apply created by filter
      if (filter.createdByUserId != null) {
        filtered = _applyCreatedByFilter(filtered, filter.createdByUserId!);
      }

      // 4. Apply chalan number range filter
      filtered = _applyChalanNumberRangeFilter(filtered, filter);

      // Emit success state
      if (!emit.isDone) {
        emit(ChalanFilterAppliedState(
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: filtered,
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(ChalanFilterErrorState(
          message: 'Error applying filters: $e',
          filter: filter,
          originalChalans: state.originalChalans,
          filteredChalans: state.filteredChalans,
        ));
      }
    }
  }

  /// Apply search filter for chalan number or date
  List<Chalan> _applySearchFilter(List<Chalan> chalans, String query) {
    final lowerQuery = query.toLowerCase();

    return chalans.where((chalan) {
      // Search in chalan number
      if (chalan.chalanNumber.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in date (format: YYYY-MM-DD or DD/MM/YYYY)
      final dateStr1 = '${chalan.dateTime.year}-${chalan.dateTime.month.toString().padLeft(2, '0')}-${chalan.dateTime.day.toString().padLeft(2, '0')}';
      final dateStr2 = '${chalan.dateTime.day}/${chalan.dateTime.month}/${chalan.dateTime.year}';

      if (dateStr1.contains(lowerQuery) || dateStr2.contains(lowerQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Apply date-based filters
  List<Chalan> _applyDateFilter(List<Chalan> chalans, ChalanFilter filter) {
    switch (filter.filterType) {
      case FilterType.thisYear:
        final currentYear = DateTime.now().year;
        return chalans.where((chalan) => chalan.dateTime.year == currentYear).toList();

      case FilterType.allYears:
        return chalans; // No date filtering

      case FilterType.byMonth:
        if (filter.specificMonth != null && filter.specificYear != null) {
          return chalans.where((chalan) =>
          chalan.dateTime.month == filter.specificMonth &&
              chalan.dateTime.year == filter.specificYear).toList();
        }
        return chalans;

      case FilterType.byDate:
        if (filter.specificDate != null) {
          return chalans.where((chalan) =>
          chalan.dateTime.year == filter.specificDate!.year &&
              chalan.dateTime.month == filter.specificDate!.month &&
              chalan.dateTime.day == filter.specificDate!.day).toList();
        }
        return chalans;

      case FilterType.createdByMe:
      // Date filtering is handled separately for this type
        return chalans;

      case FilterType.chalanNumberRange:
      // Date filtering is handled separately for this type
        return chalans;
    }
  }

  /// Apply created by filter
  List<Chalan> _applyCreatedByFilter(List<Chalan> chalans, String userId) {
    return chalans.where((chalan) => chalan.createdBy == userId).toList();
  }

  /// Apply chalan number range filter
  List<Chalan> _applyChalanNumberRangeFilter(List<Chalan> chalans, ChalanFilter filter) {
    switch (filter.chalanNumberRange) {
      case ChalanNumberRange.all:
        return chalans;

      case ChalanNumberRange.below20:
        return chalans.where((chalan) {
          final number = int.tryParse(chalan.chalanNumber) ?? 0;
          return number < 20;
        }).toList();

      case ChalanNumberRange.between20And80:
        return chalans.where((chalan) {
          final number = int.tryParse(chalan.chalanNumber) ?? 0;
          return number >= 20 && number <= 80;
        }).toList();

      case ChalanNumberRange.above80:
        return chalans.where((chalan) {
          final number = int.tryParse(chalan.chalanNumber) ?? 0;
          return number > 80;
        }).toList();
    }
  }

  /// Update original chalans list (called when new data is loaded)
  void updateOriginalChalans(List<Chalan> chalans) {
    if (isClosed) return;

    final newState = ChalanFilterAppliedState(
      filter: state.filter,
      originalChalans: chalans,
      filteredChalans: chalans,
    );

    emit(newState);

    // Reapply current filters
    add(ApplyFiltersEvent());
  }
}
