import 'package:chalan_book_app/core/models/organization.dart';

class OrganizationState {
  final List<Organization> organizations;
  final Organization? currentOrg; // Optional selected org

  const OrganizationState({this.organizations = const [], this.currentOrg});
}

class OrganizationInitial extends OrganizationState {
  const OrganizationInitial() : super();
}

class OrganizationLoading extends OrganizationState {
  const OrganizationLoading() : super();
}

class OrganizationLoaded extends OrganizationState {
  OrganizationLoaded(List<Organization> orgs, {super.currentOrg})
    : super(organizations: orgs);
}

class OrganizationFailure extends OrganizationState {
  final String message;
  const OrganizationFailure(this.message) : super();
}
