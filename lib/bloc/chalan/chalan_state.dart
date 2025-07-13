import '../../core/models/chalan.dart';

abstract class ChalanState {}

class ChalanInitialState extends ChalanState {}

class ChalanLoadingState extends ChalanState {}

class ChalanLoadedState extends ChalanState {
  final List<Chalan> chalans;
  ChalanLoadedState(this.chalans);
}

class ChalanEmptyState extends ChalanState {}

class ChalanErrorState extends ChalanState {
  final String message;
  ChalanErrorState(this.message);
}

class ChalanOperationSuccessState extends ChalanState {
  final String message;
  final List<Chalan> chalans;
  ChalanOperationSuccessState(this.message, this.chalans);
}