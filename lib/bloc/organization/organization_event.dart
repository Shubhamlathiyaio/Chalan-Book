import 'package:chalan_book_app/core/models/organization.dart';

abstract class OrganizationEvent {}

class CreateOrganizationRequested extends OrganizationEvent {
  final String name;
  final String? description;

  CreateOrganizationRequested({required this.name, this.description});
}

class OrganizationInitialEvent extends OrganizationEvent {}
class LoadOrganizationsRequested extends OrganizationEvent {}

class SelectOrganization extends OrganizationEvent {
  Organization currentOrganization;
  SelectOrganization(this.currentOrganization);
}
