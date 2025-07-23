import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/models/organization.dart';
import '../../../main.dart';

// Events
abstract class OrganizationEvent {}

class LoadOrganizations extends OrganizationEvent {}

class CreateOrganization extends OrganizationEvent {
  final String name;
  final String? description;
  CreateOrganization({required this.name, this.description});
}

class SelectOrganization extends OrganizationEvent {
  final Organization organization;
  SelectOrganization(this.organization);
}

// States
abstract class OrganizationState {
  final List<Organization> organizations;
  final Organization? currentOrg;

  const OrganizationState({
    this.organizations = const [],
    this.currentOrg,
  });
}

class OrganizationInitial extends OrganizationState {
  const OrganizationInitial() : super();
}

class OrganizationLoading extends OrganizationState {
  const OrganizationLoading() : super();
}

class OrganizationLoaded extends OrganizationState {
  const OrganizationLoaded(
    List<Organization> organizations, {
    Organization? currentOrg,
  }) : super(organizations: organizations, currentOrg: currentOrg);
}

class OrganizationError extends OrganizationState {
  final String message;
  const OrganizationError(this.message) : super();
}

// BLoC
class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  OrganizationBloc() : super(const OrganizationInitial()) {
    on<LoadOrganizations>(_onLoadOrganizations);
    on<CreateOrganization>(_onCreateOrganization);
    on<SelectOrganization>(_onSelectOrganization);
    
    _initializeCache();
  }

  void _initializeCache() {
    add(LoadOrganizations());
  }

  Future<void> _onLoadOrganizations(
    LoadOrganizations event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(const OrganizationLoading());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from(organizationUsersTable)
          .select('organization_id, organizations:organization_id(*)')
          .eq('user_id', user.id);

      final orgs = response
          .where((row) => row['organizations'] != null)
          .map<Organization>((row) => Organization.fromJson(row['organizations']))
          .toList();

      if (orgs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final cachedId = prefs.getString(selectedOrgId);
        final selectedOrg = orgs.firstWhere(
          (org) => org.id == cachedId,
          orElse: () => orgs.first,
        );
        emit(OrganizationLoaded(orgs, currentOrg: selectedOrg));
      } else {
        emit(const OrganizationLoaded([]));
      }
    } catch (e) {
      emit(OrganizationError(e.toString()));
    }
  }

  Future<void> _onCreateOrganization(
    CreateOrganization event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(const OrganizationLoading());

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
        'description': event.description?.trim(),
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

      add(LoadOrganizations());
    } catch (e) {
      emit(OrganizationError(e.toString()));
    }
  }

  Future<void> _onSelectOrganization(
    SelectOrganization event,
    Emitter<OrganizationState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedOrgId, event.organization.id);

    if (state is OrganizationLoaded) {
      final currentState = state as OrganizationLoaded;
      emit(OrganizationLoaded(
        currentState.organizations,
        currentOrg: event.organization,
      ));
    }
  }
}
