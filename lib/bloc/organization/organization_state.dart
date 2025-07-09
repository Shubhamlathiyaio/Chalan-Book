import 'package:chalan_book_app/core/models/organization.dart';

abstract class OrganizationState {}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationLoaded extends OrganizationState {
  final List<Organization> organizations;
  OrganizationLoaded(this.organizations);
}

class OrganizationCreatedSuccess extends OrganizationState {}


class ChangeTheCurruntOrganization extends OrganizationState {
  final Organization curruntOrgaization;
  ChangeTheCurruntOrganization({required this.curruntOrgaization});
}

class OrganizationFailure extends OrganizationState {
  final String message;
  OrganizationFailure(this.message);
}
