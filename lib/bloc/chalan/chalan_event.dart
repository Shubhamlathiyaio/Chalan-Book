import '../../core/models/chalan.dart';
import '../../core/models/organization.dart';

abstract class ChalanEvent {}

class LoadChalansEvent extends ChalanEvent {
  final Organization organization;
  LoadChalansEvent(this.organization);
}

class AddChalanEvent extends ChalanEvent {
  final Chalan chalan;
  AddChalanEvent(this.chalan);
}

class UpdateChalanEvent extends ChalanEvent {
  final Chalan chalan;
  UpdateChalanEvent(this.chalan);
}

class DeleteChalanEvent extends ChalanEvent {
  final Chalan chalan;
  DeleteChalanEvent(this.chalan);
}

class ViewChalanEvent extends ChalanEvent {
  final Chalan chalan;
  ViewChalanEvent(this.chalan);
}

class RefreshChalansEvent extends ChalanEvent {
  final Organization organization;
  RefreshChalansEvent(this.organization);
}