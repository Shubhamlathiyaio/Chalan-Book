import 'package:chalan_book_app/core/models/organization.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Organization> organizations;
  final Organization currentOrganization;

  HomeLoaded({required this.organizations, required this.currentOrganization});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
