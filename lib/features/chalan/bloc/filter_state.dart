import '../../../core/models/chalan.dart';
import '../models/advanced_filter_model.dart';

/// Base class for all advanced filter states
abstract class FilterState {
  final AdvancedChalanFilter filter;
  final List<Chalan> originalChalans;
  final List<Chalan> filteredChalans;
  final bool isLoading;

  const FilterState({
    required this.filter,
    required this.originalChalans,
    required this.filteredChalans,
    this.isLoading = false,
  });
}

/// Initial state
class AdvancedChalanFilterInitialState extends FilterState {
  const AdvancedChalanFilterInitialState()
    : super(
        filter: const AdvancedChalanFilter(),
        originalChalans: const [],
        filteredChalans: const [],
      );
}

/// Loading state
class AdvancedChalanFilterLoadingState extends FilterState {
  const AdvancedChalanFilterLoadingState({
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  }) : super(isLoading: true);
}

/// Applied state
class AdvancedChalanFilterAppliedState extends FilterState {
  const AdvancedChalanFilterAppliedState({
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}

/// Error state
class AdvancedChalanFilterErrorState extends FilterState {
  final String message;

  const AdvancedChalanFilterErrorState({
    required this.message,
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}
