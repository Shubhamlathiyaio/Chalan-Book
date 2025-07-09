import 'package:chalan_book_app/core/models/organization.dart';

abstract class HomeEvent {}

class LoadOrganizations extends HomeEvent {
  final Organization? org;
  LoadOrganizations([this.org]);
}

class HomeInitalEvent extends HomeEvent {}

class ChangeTab extends HomeEvent {
  final int newIndex;
  ChangeTab(this.newIndex);
}
