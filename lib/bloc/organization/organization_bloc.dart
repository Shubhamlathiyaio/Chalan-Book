import 'package:chalan_book_app/bloc/organization/organization_event.dart';
import 'package:chalan_book_app/bloc/organization/organization_state.dart';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  Organization? selectedOrg;
  Organization? get currentOrg => selectedOrg;
  OrganizationBloc() : super(OrganizationInitial()) {
    // on<OrganizationInitialEvent>(
    //   (OrganizationInitialEvent event, Emitter<OrganizationState> emit)  listen<OrganizationState>{},
    // );
    on<CreateOrganizationRequested>(_onCreateOrganization);
    on<LoadOrganizationsRequested>(_onLoadOrganizations);
    on<SelectOrganization>(_onSelectOrganization);
  }
  Future<void> _onCreateOrganization(
    CreateOrganizationRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(OrganizationLoading());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final existing = await supabase
          .from(organizationsTable)
          .select('id')
          .eq('name', event.name.trim())
          .maybeSingle();

      if (existing != null) {
        throw Exception('Organization name already exists');
      }

      final orgId = const Uuid().v4();
      await supabase.from(organizationsTable).insert({
        'id': orgId,
        'name': event.name.trim(),
        'owner_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabase.from(organizationUsersTable).insert({
        'id': const Uuid().v4(),
        'organization_id': orgId,
        'user_id': user.id,
        'email': user.email,
        'role': 'admin',
        'joined_at': DateTime.now().toIso8601String(),
      });

      emit(OrganizationCreatedSuccess());
    } catch (e) {
      emit(OrganizationFailure(e.toString()));
    }
  }

  Future<void> _onLoadOrganizations(
    LoadOrganizationsRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(OrganizationLoading());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from(organizationUsersTable)
          .select('organization_id, organizations:organization_id(*)')
          .eq('user_id', user.id);

      final orgs = response
          .where((row) => row['organizations'] != null)
          .map<Organization>(
            (row) => Organization.fromJson(row['organizations']),
          )
          .toList();

      selectedOrg ??= orgs.isNotEmpty ? orgs.first : null;

      emit(OrganizationLoaded(orgs));
    } catch (e) {
      emit(OrganizationFailure(e.toString()));
    }
  }

  _onSelectOrganization(
    SelectOrganization event,
    Emitter<OrganizationState> emit,
  ) {
    selectedOrg = event.currentOrganization;
  }
}
