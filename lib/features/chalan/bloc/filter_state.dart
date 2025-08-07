import '../../../core/models/chalan.dart';
import '../models/advanced_filter_model.dart';

/// Base class for all advanced filter states
abstract class FilterState {
  final AdvancedChalanFilter filter;
  final List<Chalan> originalChalans;
  final List<Chalan> filteredChalans;
  // final bool isLoading;

  const FilterState({
    required this.filter,
    required this.originalChalans,
    required this.filteredChalans,
    // this.isLoading = false,
  });
}

/// Initial state
class FilterInitialState extends FilterState {
  const FilterInitialState()
    : super(
        filter: const AdvancedChalanFilter(),
        originalChalans: const [],
        filteredChalans: const [],
      );
}

/// Loading state
class FilterLoadingState extends FilterState {
  const FilterLoadingState({
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  }) : super();
}

/// Applied state
class FilterAppliedState extends FilterState {
  const FilterAppliedState({
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}

/// Error state
class FilterErrorState extends FilterState {
  final String message;

  const FilterErrorState({
    required this.message,
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}
