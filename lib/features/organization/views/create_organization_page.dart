// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../../core/constants/app_keys.dart';
// import '../../../core/models/organization.dart';
// import '../../../core/models/organization_member.dart';
// import '../../../main.dart';

// // -------- EVENTS --------
// abstract class OrganizationEvent {}

// class LoadOrganizations extends OrganizationEvent {}
// class CreateOrganization extends OrganizationEvent {
//   final String name;
//   final String? description;
//   CreateOrganization({required this.name, this.description});
// }
// class SelectOrganization extends OrganizationEvent {
//   final Organization organization;
//   SelectOrganization(this.organization);
// }

// class LoadOrganizationMembers extends OrganizationEvent {
//   final String organizationId;
//   LoadOrganizationMembers(this.organizationId);
// }

// class ScanQRCode extends OrganizationEvent {}
// class SelectQRFromGallery extends OrganizationEvent {}
// class ProcessQRResult extends OrganizationEvent {
//   final String qrData;
//   final String organizationId;
//   ProcessQRResult({required this.qrData, required this.organizationId});
// }
// class AddMemberByUserId extends OrganizationEvent {
//   final String userId;
//   final String organizationId;
//   AddMemberByUserId({required this.userId, required this.organizationId});
// }

// // -------- STATES --------
// class OrganizationState {
//   final List<Organization> organizations;
//   final Organization? currentOrg;
//   final List<OrganizationMember> members;
//   final bool isOrgLoading;
//   final bool isMemberLoading;
//   final bool isAddingMember;
//   final bool isQRScanning;
//   final String? message;
//   final String? error;

//   OrganizationState({
//     this.organizations = const [],
//     this.currentOrg,
//     this.members = const [],
//     this.isOrgLoading = false,
//     this.isMemberLoading = false,
//     this.isAddingMember = false,
//     this.isQRScanning = false,
//     this.message,
//     this.error,
//   });

//   OrganizationState copyWith({
//     List<Organization>? organizations,
//     Organization? currentOrg,
//     List<OrganizationMember>? members,
//     bool? isOrgLoading,
//     bool? isMemberLoading,
//     bool? isAddingMember,
//     bool? isQRScanning,
//     String? message,
//     String? error,
//   }) {
//     return OrganizationState(
//       organizations: organizations ?? this.organizations,
//       currentOrg: currentOrg ?? this.currentOrg,
//       members: members ?? this.members,
//       isOrgLoading: isOrgLoading ?? this.isOrgLoading,
//       isMemberLoading: isMemberLoading ?? this.isMemberLoading,
//       isAddingMember: isAddingMember ?? this.isAddingMember,
//       isQRScanning: isQRScanning ?? this.isQRScanning,
//       message: message,
//       error: error,
//     );
//   }
// }

// // -------- BLOC --------
// class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
//   final ImagePicker _imagePicker = ImagePicker();

//   OrganizationBloc() : super(OrganizationState()) {
//     on<LoadOrganizations>(_onLoadOrganizations);
//     on<CreateOrganization>(_onCreateOrganization);
//     on<SelectOrganization>(_onSelectOrganization);

//     on<LoadOrganizationMembers>(_onLoadMembers);
//     on<ScanQRCode>(_onScanQR);
//     on<SelectQRFromGallery>(_onSelectQRFromGallery);
//     on<ProcessQRResult>(_onProcessQRResult);
//     on<AddMemberByUserId>(_onAddMemberByUserId);

//     _initializeCache();
//   }

//   void _initializeCache() {
//     add(LoadOrganizations());
//   }

//   // ---- Organization handlers ----
//   Future<void> _onLoadOrganizations(
//     LoadOrganizations event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     emit(state.copyWith(isOrgLoading: true, error: null));
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');

//       final response = await supabase
//           .from(AppKeys.organizationUsersTable)
//           .select('organization_id, organizations:organization_id(*)')
//           .eq('user_id', user.id);

//       final orgs = response
//           .where((row) => row['organizations'] != null)
//           .map<Organization>(
//             (row) => Organization.fromJson(row['organizations']),
//           )
//           .toList();

//       if (orgs.isNotEmpty) {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedId = prefs.getString(AppKeys.selectedOrgId);
//         final selectedOrg = orgs.firstWhere(
//           (org) => org.id == cachedId,
//           orElse: () => orgs.first,
//         );
//         emit(state.copyWith(
//           organizations: orgs,
//           currentOrg: selectedOrg,
//           isOrgLoading: false,
//         ));
//         add(LoadOrganizationMembers(selectedOrg.id)); // auto-load members
//       } else {
//         emit(state.copyWith(organizations: [], isOrgLoading: false));
//       }
//     } catch (e) {
//       emit(state.copyWith(isOrgLoading: false, error: e.toString()));
//     }
//   }

//   Future<void> _onCreateOrganization(
//     CreateOrganization event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     emit(state.copyWith(isOrgLoading: true));
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');

//       final existing = await supabase
//           .from(AppKeys.organizationsTable)
//           .select('id')
//           .eq('name', event.name.trim())
//           .maybeSingle();

//       if (existing != null) {
//         throw Exception('Organization name already exists');
//       }

//       final orgId = const Uuid().v4();
//       await supabase.from(AppKeys.organizationsTable).insert({
//         'id': orgId,
//         'name': event.name.trim(),
//         'description': event.description?.trim(),
//         'owner_id': user.id,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       await supabase.from(AppKeys.organizationUsersTable).insert({
//         'id': const Uuid().v4(),
//         'organization_id': orgId,
//         'user_id': user.id,
//         'role': 'admin',
//         'joined_at': DateTime.now().toIso8601String(),
//       });

//       add(LoadOrganizations());
//     } catch (e) {
//       emit(state.copyWith(isOrgLoading: false, error: e.toString()));
//     }
//   }

//   Future<void> _onSelectOrganization(
//     SelectOrganization event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(AppKeys.selectedOrgId, event.organization.id);

//     emit(state.copyWith(currentOrg: event.organization));
//     add(LoadOrganizationMembers(event.organization.id));
//   }

//   // ---- Members handlers ----
//   Future<void> _onLoadMembers(
//     LoadOrganizationMembers event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     emit(state.copyWith(isMemberLoading: true));
//     try {
//       final response = await supabase
//           .from(AppKeys.organizationUsersTable)
//           .select('*, users:user_id(email)')
//           .eq('organization_id', event.organizationId);

//       final members = response.map<OrganizationMember>((item) {
//         return OrganizationMember(
//           id: item['id'],
//           organizationId: item['organization_id'],
//           userId: item['user_id'],
//           email: item['users']?['email'] ?? 'Unknown',
//           role: item['role'],
//           joinedAt: DateTime.parse(item['joined_at']),
//         );
//       }).toList();

//       emit(state.copyWith(members: members, isMemberLoading: false));
//     } catch (e) {
//       emit(state.copyWith(isMemberLoading: false, error: e.toString()));
//     }
//   }

//   // ---- QR & Member Add handlers ----
//   Future<void> _onScanQR(
//     ScanQRCode event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     emit(state.copyWith(isQRScanning: true));
//   }

//   Future<void> _onSelectQRFromGallery(
//     SelectQRFromGallery event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(isQRScanning: true));
//       final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);

//       if (image != null) {
//         emit(state.copyWith(error: 'QR detection from gallery not implemented yet'));
//       } else {
//         emit(state.copyWith(error: 'No image selected'));
//       }
//     } catch (e) {
//       emit(state.copyWith(error: e.toString(), isQRScanning: false));
//     }
//   }

//   Future<void> _onProcessQRResult(
//     ProcessQRResult event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     try {
//       final userId = event.qrData;
//       if (userId.length != 36 || !RegExp(r'^[0-9a-f-]+$').hasMatch(userId)) {
//         emit(state.copyWith(error: 'Invalid QR code format'));
//         return;
//       }
//       add(AddMemberByUserId(userId: userId, organizationId: event.organizationId));
//     } catch (e) {
//       emit(state.copyWith(error: e.toString()));
//     }
//   }

//   Future<void> _onAddMemberByUserId(
//     AddMemberByUserId event,
//     Emitter<OrganizationState> emit,
//   ) async {
//     emit(state.copyWith(isAddingMember: true));
//     try {
//       final userResponse = await supabase
//           .from('users')
//           .select('email')
//           .eq('id', event.userId)
//           .maybeSingle();

//       if (userResponse == null) {
//         emit(state.copyWith(isAddingMember: false, error: 'User not found'));
//         return;
//       }

//       final existingMember = await supabase
//           .from(AppKeys.organizationUsersTable)
//           .select('id')
//           .eq('organization_id', event.organizationId)
//           .eq('user_id', event.userId)
//           .maybeSingle();

//       if (existingMember != null) {
//         emit(state.copyWith(isAddingMember: false, error: 'User is already a member'));
//         return;
//       }

//       final memberId = const Uuid().v4();
//       await supabase.from(AppKeys.organizationUsersTable).insert({
//         'id': memberId,
//         'organization_id': event.organizationId,
//         'user_id': event.userId,
//         'role': 'member',
//         'joined_at': DateTime.now().toIso8601String(),
//       });

//       emit(state.copyWith(message: 'Member added successfully!'));
//       add(LoadOrganizationMembers(event.organizationId));
//     } catch (e) {
//       emit(state.copyWith(isAddingMember: false, error: e.toString()));
//     }
//   }
// }
