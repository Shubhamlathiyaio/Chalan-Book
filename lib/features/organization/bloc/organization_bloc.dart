import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/models/organization.dart';
import '../../../core/models/organization_member.dart';

// ------------------- EVENTS -------------------
abstract class OrganizationEvent {}

// Organization CRUD
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

// Member management
class LoadOrganizationMembers extends OrganizationEvent {
  final String organizationId;
  LoadOrganizationMembers(this.organizationId);
}

class ScanQRCode extends OrganizationEvent {}

class SelectQRFromGallery extends OrganizationEvent {}

class ProcessQRResult extends OrganizationEvent {
  final String qrData;
  final String organizationId;
  ProcessQRResult({required this.qrData, required this.organizationId});
}

class AddMemberByUserId extends OrganizationEvent {
  final String userId;
  final String organizationId;
  AddMemberByUserId({required this.userId, required this.organizationId});
}

// ------------------- STATES -------------------
// Base State
abstract class OrganizationState {
  final List<Organization> organizations;
  final Organization? currentOrg;
  final List<OrganizationMember> members;
  final String? message;
  const OrganizationState({
    this.organizations = const [],
    this.currentOrg,
    this.members = const [],
    this.message,
  });
}

// Initial
class OrganizationInitial extends OrganizationState {
  const OrganizationInitial();
}

// Loading
class OrganizationLoading extends OrganizationState {
  const OrganizationLoading({
    super.organizations,
    super.currentOrg,
    super.members,
    super.message,
  });
}

// Success State (replaces old OrganizationLoaded but keeps old name for UI)
class OrganizationSuccess extends OrganizationState {
  const OrganizationSuccess({
    required super.organizations,
    super.currentOrg,
    super.members,
    super.message,
  });
}

// Failure State (old OrganizationFailure)
class OrganizationFailure extends OrganizationState {
  const OrganizationFailure(
    String message, {
    super.organizations,
    super.currentOrg,
    super.members,
  }) : super(message: message);
}

// Old QR Related States
class QRScanningState extends OrganizationState {
  const QRScanningState({
    super.organizations,
    super.currentOrg,
    super.members,
    super.message,
  });
}

class AddingMemberState extends OrganizationState {
  const AddingMemberState({
    super.organizations,
    super.currentOrg,
    super.members,
    super.message,
  });
}

class OrganizationLoaded extends OrganizationState {
  const OrganizationLoaded({
    required super.organizations,
    super.currentOrg,
    super.members,
    super.message,
  });
}

class OrganizationError extends OrganizationState {
  const OrganizationError({
    required super.message,
    super.organizations,
    super.currentOrg,
    super.members,
  });
}

// ------------------- MERGED BLOC -------------------
class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final supa = Supa();
  final ImagePicker _imagePicker = ImagePicker();

  OrganizationBloc() : super(const OrganizationInitial()) {
    // Org
    on<LoadOrganizations>(_onLoadOrganizations);
    on<CreateOrganization>(_onCreateOrganization);
    on<SelectOrganization>(_onSelectOrganization);

    // Members
    on<LoadOrganizationMembers>(_onLoadMembers);
    on<ScanQRCode>(_onScanQR);
    on<SelectQRFromGallery>(_onSelectFromGallery);
    on<ProcessQRResult>(_onProcessQRResult);
    on<AddMemberByUserId>(_onAddMemberByUserId);

    add(LoadOrganizations());
  }

  // ------------- Organization Logic -----------------
  Future<void> _onLoadOrganizations(
    LoadOrganizations event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(
      OrganizationLoading(
        organizations: state.organizations,
        currentOrg: state.currentOrg,
        members: state.members,
      ),
    );
    try {
      final user = supa.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supa
          .from(AppKeys.organizationUsersTable)
          .select('organization_id, organizations:organization_id(*)')
          .eq('user_id', user.id);

      final orgs = response
          .where((row) => row['organizations'] != null)
          .map<Organization>(
            (row) => Organization.fromJson(row['organizations']),
          )
          .toList();

      if (orgs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final cachedId = prefs.getString(AppKeys.selectedOrgId);
        final selectedOrg = orgs.firstWhere(
          (org) => org.id == cachedId,
          orElse: () => orgs.first,
        );
        emit(
          OrganizationLoaded(
            organizations: orgs,
            currentOrg: selectedOrg,
            members: state.members,
          ),
        );
      } else {
        emit(const OrganizationLoaded(organizations: []));
      }
    } catch (e) {
      emit(OrganizationError(message: e.toString()));
    }
  }

  Future<void> _onCreateOrganization(
    CreateOrganization event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(
      OrganizationLoading(
        organizations: state.organizations,
        currentOrg: state.currentOrg,
        members: state.members,
      ),
    );
    try {
      final user = supa.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final existing = await supa
          .from(AppKeys.organizationsTable)
          .select('id')
          .eq('name', event.name.trim())
          .maybeSingle();

      if (existing != null) {
        throw Exception('Organization name already exists');
      }

      final orgId = const Uuid().v4();
      await supa.from(AppKeys.organizationsTable).insert({
        'id': orgId,
        'name': event.name.trim(),
        'description': event.description?.trim(),
        'owner_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });

      await supa.from(AppKeys.organizationUsersTable).insert({
        'id': const Uuid().v4(),
        'organization_id': orgId,
        'user_id': user.id,
        'role': 'owner',
        'joined_at': DateTime.now().toIso8601String(),
      });

      add(LoadOrganizations());
    } catch (e) {
      emit(
        OrganizationError(
          message: e.toString(),
          organizations: state.organizations,
          currentOrg: state.currentOrg,
          members: state.members,
        ),
      );
    }
  }

  Future<void> _onSelectOrganization(
    SelectOrganization event,
    Emitter<OrganizationState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.selectedOrgId, event.organization.id);

    emit(
      OrganizationLoaded(
        organizations: state.organizations,
        currentOrg: event.organization,
        members: state.members,
      ),
    );
  }

  // ------------- Member Logic -----------------
  Future<void> _onLoadMembers(
    LoadOrganizationMembers event,
    Emitter<OrganizationState> emit,
  ) async {
    print('Loading members for organization: ${event.organizationId}');
    try {
      final response = await Supa()
          .from(AppKeys.organizationUsersTable)
          .select(
            '*, profiles: user_id (email, name)',
          ) // join profiles instead of users
          .eq('organization_id', event.organizationId);

      final members = response.map<OrganizationMember>((item) {
        return OrganizationMember(
          id: item['id'],
          organizationId: item['organization_id'],
          userId: item['user_id'],
          email: item['profiles']?['email'] ?? "Unknown email",
          name: item['profiles']?['name'] ?? "Unknown",
          role: item['role'],
          joinedAt: DateTime.parse(item['joined_at']),
        );
      }).toList();

      emit(
        OrganizationLoaded(
          organizations: state.organizations,
          currentOrg: state.currentOrg,
          members: members,
        ),
      );
    } catch (e) {
      print('Failed to load members: $e');
      emit(
        OrganizationError(
          message: 'Failed to load members: $e',
          organizations: state.organizations,
          currentOrg: state.currentOrg,
          members: state.members,
        ),
      );
    }
  }

  Future<void> _onScanQR(
    ScanQRCode event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(
      OrganizationLoaded(
        organizations: state.organizations,
        currentOrg: state.currentOrg,
        members: state.members,
        message: "QR Scan Started",
      ),
    );
  }

  Future<void> _onSelectFromGallery(
    SelectQRFromGallery event,
    Emitter<OrganizationState> emit,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        emit(
          OrganizationError(
            message: 'QR detection from gallery not implemented yet',
            organizations: state.organizations,
            currentOrg: state.currentOrg,
            members: state.members,
          ),
        );
      } else {
        emit(
          OrganizationError(
            message: 'No image selected',
            organizations: state.organizations,
            currentOrg: state.currentOrg,
            members: state.members,
          ),
        );
      }
    } catch (e) {
      emit(
        OrganizationError(
          message: 'Failed to select image: $e',
          organizations: state.organizations,
          currentOrg: state.currentOrg,
          members: state.members,
        ),
      );
    }
  }

  Future<void> _onProcessQRResult(
    ProcessQRResult event,
    Emitter<OrganizationState> emit,
  ) async {
    try {
      final userId = event.qrData.trim().toLowerCase();
      if (userId.length != 36 || !RegExp(r'^[0-9a-f-]+$').hasMatch(userId)) {
        emit(
          OrganizationError(
            message: 'Invalid QR code format',
            organizations: state.organizations,
            currentOrg: state.currentOrg,
            members: state.members,
          ),
        );
        return;
      }
      add(
        AddMemberByUserId(userId: userId, organizationId: event.organizationId),
      );
    } catch (e) {
      emit(
        OrganizationError(
          message: 'Failed to process QR code: $e',
          organizations: state.organizations,
          currentOrg: state.currentOrg,
          members: state.members,
        ),
      );
    }
  }

  Future<void> _onAddMemberByUserId(
    AddMemberByUserId event,
    Emitter<OrganizationState> emit,
  ) async {
    try {
      final accessToken = Supa().authToken;
      if (accessToken == null) {
        emit(
          OrganizationError(
            message: 'User not authenticated',
            organizations: state.organizations,
            currentOrg: state.currentOrg,
            members: state.members,
          ),
        );
        return;
      }

      final supa = Supa(
        edgeFunctionUrl:
            'https://jzhrtmwaqezmrmyoqeka.supabase.co/functions/v1/add-member-in-organization',
        customAuthToken: accessToken,
      );

      print(
        'Adding member: ${event.userId} to organization: ${event.organizationId}',
      );
      final res = await supa.addMemberToOrganization(
        organizationId: event.organizationId,
        userId: event.userId,
      );

      if (res?.statusCode == 200) {
        print('Success! 🎉 Member added');
        add(LoadOrganizationMembers(event.organizationId));
      } else {
        print('Failed to add member: ${res?.body}');
        emit(
          OrganizationError(
            message: 'Failed to add member: ${res?.body}',
            organizations: state.organizations,
            currentOrg: state.currentOrg,
            members: state.members,
          ),
        );
      }
    } catch (e) {
      print('AddMember error: $e');
      emit(
        OrganizationError(
          message: 'Failed to add member: $e',
          organizations: state.organizations,
          currentOrg: state.currentOrg,
          members: state.members,
        ),
      );
    }
  }
}
