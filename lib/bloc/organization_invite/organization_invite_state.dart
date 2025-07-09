import 'package:chalan_book_app/core/models/organization_member.dart';

abstract class OrganizationInviteState {}

class OrganizationInviteInitial extends OrganizationInviteState {}

class OrganizationInviteLoading extends OrganizationInviteState {}

class OrganizationInviteSuccess extends OrganizationInviteState {
  final List<OrganizationMember> members;
  OrganizationInviteSuccess(this.members);
}

class OrganizationInviteFailure extends OrganizationInviteState {
  final String message;
  OrganizationInviteFailure(this.message);
}

class OrganizationInviteSending extends OrganizationInviteState {}

class OrganizationInviteSent extends OrganizationInviteState {}
