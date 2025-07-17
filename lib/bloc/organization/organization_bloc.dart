import 'package:chalan_book_app/bloc/organization/organization_event.dart';
import 'package:chalan_book_app/bloc/organization/organization_state.dart';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/shared/widgets/organization_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  OrganizationBloc() : super(OrganizationInitial()) {
    // on<OrganizationInitialEvent>(
    //   (OrganizationInitialEvent event, Emitter<OrganizationState> emit)  listen<OrganizationState>{},
    // );
    on<CreateOrganizationRequested>(_onCreateOrganization);
    on<LoadOrganizationsRequested>(_onLoadOrganizations);
    on<SelectOrganization>(_onSelectOrganization);

    _initializeCache();
  }

  void _initializeCache() {
    if (state.currentOrg == null) {
      // add(SelectOrganization(currentOrganization))
    }
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

      emit(OrganizationState());
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

      // 👇 Load selected org ID from cache
      if(orgs.isNotEmpty){
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString(selectedOrgId);
    final selectedOrg = orgs.firstWhere(
      (org) => org.id == cachedId,
      orElse: () => orgs.first,
    );
    return emit(OrganizationLoaded(orgs, currentOrg: selectedOrg));
    }
    return emit(OrganizationLoaded(orgs));

    } catch (e) {
      emit(OrganizationFailure(e.toString()));
    }
  }

  _onSelectOrganization(
    SelectOrganization event,
    Emitter<OrganizationState> emit,
  ) async {
    // Save selected organization ID to cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedOrgId, event.currentOrganization.id);

    // ✅ Fix: Keep existing organizations and update current org
    if (state is OrganizationLoaded) {
      final currentState = state as OrganizationLoaded;
      emit(
        OrganizationLoaded(
          currentState.organizations,
          currentOrg: event.currentOrganization,
        ),
      );
    }
    // The else part will be called
    else {
      emit(OrganizationState(currentOrg: event.currentOrganization));
    }
  }

  @override
  void onChange(Change<OrganizationState> change) {
    super.onChange(change);
    print('OrganizationBloc change: $change');
  }

  @override
  void onTransition(
    Transition<OrganizationEvent, OrganizationState> transition,
  ) {
    print('OrganizationBloc transition: $transition');
    super.onTransition(transition);
  }
}
