import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/models/organization_member.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_invite/organization_invite_event.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_invite/organization_invite_state.dart';
import 'package:chalan_book_app/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class OrganizationInviteBloc extends Bloc<OrganizationInviteEvent, OrganizationInviteState> {
  OrganizationInviteBloc() : super(OrganizationInviteInitial()) {
    on<LoadOrganizationMembers>(_onLoadMembers);
    on<SendOrganizationInvite>(_onSendInvite);
  }

  Future<void> _onLoadMembers(
    LoadOrganizationMembers event,
    Emitter<OrganizationInviteState> emit,
  ) async {
    emit(OrganizationInviteLoading());
    try {
      final response = await supabase
          .from(organizationUsersTable)
          .select('*')
          .eq('organization_id', event.organizationId);

      final members = response.map<OrganizationMember>((item) {
        return OrganizationMember(
          id: item['id'],
          organizationId: item['organization_id'],
          userId: item['user_id'],
          email: item['email'] ?? 'Unknown',
          role: item['role'],
          joinedAt: DateTime.parse(item['joined_at']),
        );
      }).toList();

      emit(OrganizationInviteSuccess(members));
    } catch (e) {
      emit(OrganizationInviteFailure('Failed to load members: $e'));
    }
  }

  Future<void> _onSendInvite(
    SendOrganizationInvite event,
    Emitter<OrganizationInviteState> emit,
  ) async {
    emit(OrganizationInviteSending());
    try {
      final inviteId = const Uuid().v4();
      await supabase.from('organization_invites').insert({
        'id': inviteId,
        'organization_id': event.organizationId,
        'email': event.email,
      });

      emit(OrganizationInviteSent());
      add(LoadOrganizationMembers(event.organizationId)); // Refresh
    } catch (e) {
      emit(OrganizationInviteFailure('Invite failed: $e'));
    }
  }
}
