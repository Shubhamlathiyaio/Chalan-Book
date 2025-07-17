import '../../../core/models/chalan.dart';
import '../../features/filter/filter_model.dart';

/// Base class for all filter states
abstract class ChalanFilterState {
  final ChalanFilter filter;
  final List<Chalan> originalChalans;
  final List<Chalan> filteredChalans;

  const ChalanFilterState({
    required this.filter,
    required this.originalChalans,
    required this.filteredChalans,
  });
}

/// Initial state
class ChalanFilterInitialState extends ChalanFilterState {
  const ChalanFilterInitialState()
      : super(
    filter: const ChalanFilter(),
    originalChalans: const [],
    filteredChalans: const [],
  );
}

/// State when filters are being applied
class ChalanFilterLoadingState extends ChalanFilterState {
  const ChalanFilterLoadingState({
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}

/// State when filters are successfully applied
class ChalanFilterAppliedState extends ChalanFilterState {
  const ChalanFilterAppliedState({
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}

/// State when there's an error in filtering
class ChalanFilterErrorState extends ChalanFilterState {
  final String message;

  const ChalanFilterErrorState({
    required this.message,
    required super.filter,
    required super.originalChalans,
    required super.filteredChalans,
  });
}
