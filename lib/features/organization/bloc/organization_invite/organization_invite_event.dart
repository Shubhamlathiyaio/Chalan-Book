abstract class OrganizationInviteEvent {}

class LoadOrganizationMembers extends OrganizationInviteEvent {
  final String organizationId;
  LoadOrganizationMembers(this.organizationId);
}

class SendOrganizationInvite extends OrganizationInviteEvent {
  final String email;
  final String organizationId;
  SendOrganizationInvite({required this.email, required this.organizationId});
}
