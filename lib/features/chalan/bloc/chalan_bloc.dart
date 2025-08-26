import 'dart:async';
import 'dart:io';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/services/mega_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/models/chalan.dart';
import '../../organization/bloc/organization_bloc.dart';

// ################################################################################
// #                                    EVENTS                                    #
// ################################################################################
abstract class ChalanEvent {}

class LoadChalansEvent extends ChalanEvent {
  final Organization organization;
  LoadChalansEvent(this.organization);
}

class AddChalanEvent extends ChalanEvent {
  final Chalan chalan;
  AddChalanEvent(this.chalan);
}

class UpdateChalanEvent extends ChalanEvent {
  final Chalan chalan;
  UpdateChalanEvent(this.chalan);
}

class DeleteChalanEvent extends ChalanEvent {
  final Chalan chalan;
  DeleteChalanEvent(this.chalan);
}

class ShowChalanLoading extends ChalanEvent {}

class RefreshChalansEvent extends ChalanEvent {
  final Organization organization;
  RefreshChalansEvent(this.organization);
}

class SelectChalanNumberEvent extends ChalanEvent {
  final int selectedNumber;
  SelectChalanNumberEvent(this.selectedNumber);
}

class PickImageFromCamera extends ChalanEvent {}

class PickImageFromGallery extends ChalanEvent {}

class RemoveImage extends ChalanEvent {}

class UpdateChalanDate extends ChalanEvent {
  final DateTime date;
  UpdateChalanDate(this.date);
}

class PickChalanDate extends ChalanEvent {
  final BuildContext context;
  final DateTime initialDate;

  PickChalanDate({required this.context, required this.initialDate});
}

// ################################################################################
// #                                    STATES                                    #
// ################################################################################
abstract class ChalanState {}

class ChalanInitial extends ChalanState {}

class ChalanLoading extends ChalanState {}

class ChalanLoaded extends ChalanState {
  final List<Chalan> chalans;
  final int? selectedNumber;
  final File? selectedImage;
  final DateTime selectedDate;

  ChalanLoaded({
    required this.chalans,
    this.selectedNumber,
    this.selectedImage,
    required this.selectedDate,
  });

  // ✅ Helper methods for easy copying
  ChalanLoaded copyWith({
    List<Chalan>? chalans,
    int? selectedNumber,
    File? selectedImage,
    DateTime? selectedDate,
  }) {
    return ChalanLoaded(
      chalans: chalans ?? this.chalans,
      selectedNumber: selectedNumber ?? this.selectedNumber,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class ChalanEmpty extends ChalanState {}

class ChalanError extends ChalanState {
  final String message;
  ChalanError(this.message);
}

// ################################################################################
// #                                     BLOC                                     #
// ################################################################################
class ChalanBloc extends Bloc<ChalanEvent, ChalanState> {
  final OrganizationBloc organizationBloc;
  StreamSubscription? _organizationSubscription;

  ChalanBloc({required this.organizationBloc}) : super(ChalanInitial()) {
    on<LoadChalansEvent>(_onLoadChalans);
    on<AddChalanEvent>(_onAddChalan);
    on<UpdateChalanEvent>(_onUpdateChalan);
    on<DeleteChalanEvent>(_onDeleteChalan);
    on<RefreshChalansEvent>(_onRefreshChalans);
    on<SelectChalanNumberEvent>(_onSelectChalanNumber);
    on<PickImageFromCamera>(_onPickImageFromCamera);
    on<PickImageFromGallery>(_onPickImageFromGallery);
    on<RemoveImage>(_onRemoveImage);
    on<PickChalanDate>(_onPickChalanDate);

    _initializeOrganizationListener(); // ✅ Already listening to org changes
  }

  void _initializeOrganizationListener() {
    _organizationSubscription = organizationBloc.stream.listen((orgState) {
      if (orgState is OrganizationLoaded && orgState.currentOrg != null) {
        add(
          LoadChalansEvent(orgState.currentOrg!),
        ); // ✅ Auto-load chalans when org changes
      }
    });

    // Load initial data
    if (organizationBloc.state is OrganizationLoaded) {
      final state = organizationBloc.state as OrganizationLoaded;
      if (state.currentOrg != null) {
        add(LoadChalansEvent(state.currentOrg!));
      }
    }
  }

  @override
  Future<void> close() {
    _organizationSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadChalans(
    LoadChalansEvent event,
    Emitter<ChalanState> emit,
  ) async {
    emit(ChalanLoading());

    try {
      final response = await supabase
          .from(AppKeys.chalansTable)
          .select()
          .eq('organization_id', event.organization.id);

      final chalans = response.map((e) => Chalan.fromJson(e)).toList();

      if (chalans.isEmpty) return emit(ChalanEmpty());

      // 🔄 Optional: Validate Mega URLs (remove invalid ones)
      final validChalans = chalans.where((chalan) {
        return chalan.imageUrl == null ||
            chalan.imageUrl!.contains('mega.nz') ||
            chalan.imageUrl!.contains('mega.co.nz');
      }).toList();

      emit(
        ChalanLoaded(
          chalans: validChalans,
          selectedNumber: null,
          selectedImage: null,
          selectedDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(ChalanError('Error loading chalans: $e'));
    }
  }

  Future<void> _onAddChalan(
    AddChalanEvent event,
    Emitter<ChalanState> emit,
  ) async {
    emit(ChalanLoading());

    try {
      await supabase.from(AppKeys.chalansTable).insert(event.chalan.toJson());

      // Reload fresh data
      final response = await supabase
          .from(AppKeys.chalansTable)
          .select()
          .eq('organization_id', event.chalan.organizationId);

      final chalans = response.map((e) => Chalan.fromJson(e)).toList();

      emit(
        ChalanLoaded(
          chalans: chalans,
          selectedNumber: null,
          selectedImage: null,
          selectedDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(ChalanError('Error adding chalan: $e'));
    }
  }

  Future<void> _onUpdateChalan(
    UpdateChalanEvent event,
    Emitter<ChalanState> emit,
  ) async {
    try {
      await supabase
          .from(AppKeys.chalansTable)
          .update(event.chalan.toJson())
          .eq('id', event.chalan.id);

      if (state is ChalanLoaded) {
        final current = state as ChalanLoaded;
        final updated = List<Chalan>.from(current.chalans);
        final index = updated.indexWhere((c) => c.id == event.chalan.id);

        if (index != -1) {
          updated[index] = event.chalan;
          emit(current.copyWith(chalans: updated));
        }
      }
    } catch (e) {
      emit(ChalanError('Error updating chalan: $e'));
    }
  }

Future<void> _onDeleteChalan(
    DeleteChalanEvent event,
    Emitter<ChalanState> emit,
) async {
  try {
    // 1. Record image to deleted_images table
    try {
      await supabase.from('deleted_images').insert({
        'image_url': event.chalan.imageUrl,
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
        'chalan_id': event.chalan.id,
        'note': 'Marked for manual deletion',
      });
      print('Deleted image URL logged successfully');
    } catch (e) {
      print('Failed to log deleted image URL: $e');
    }

    // 2. Delete chalan record
    try {
      await supabase
        .from(AppKeys.chalansTable)
        .delete()
        .eq('id', event.chalan.id);
      print('Chalan deleted successfully');
    } catch (e) {
      print('Failed to delete chalan: $e');
      throw Exception('Delete failed: $e');
    }

    // 3. Update state
    if (state is ChalanLoaded) {
      final current = state as ChalanLoaded;
      final updated = List<Chalan>.from(current.chalans)
        ..removeWhere((c) => c.id == event.chalan.id);

      if (updated.isEmpty) {
        emit(ChalanEmpty());
      } else {
        emit(current.copyWith(chalans: updated));
      }
    }
  } catch (e) {
    emit(ChalanError('Error deleting chalan: $e'));
  }
}

  void _onUpdateChalanDate(UpdateChalanDate event, Emitter<ChalanState> emit) {
    if (state is ChalanLoaded) {
      emit((state as ChalanLoaded).copyWith(selectedDate: event.date));
    }
  }

  Future<void> _onRefreshChalans(
    RefreshChalansEvent event,
    Emitter<ChalanState> emit,
  ) async {
    add(LoadChalansEvent(event.organization));
  }

  void _onSelectChalanNumber(
    SelectChalanNumberEvent event,
    Emitter<ChalanState> emit,
  ) {
    if (state is ChalanLoaded) {
      emit(
        (state as ChalanLoaded).copyWith(selectedNumber: event.selectedNumber),
      );
    }
  }

  Future<void> _onPickImageFromCamera(
    PickImageFromCamera event,
    Emitter<ChalanState> emit,
  ) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    if (state is ChalanLoaded) {
      emit((state as ChalanLoaded).copyWith(selectedImage: imageFile));
    } else {
      emit((state as ChalanLoaded).copyWith(selectedImage: imageFile));
    }
  }

  Future<void> _onPickImageFromGallery(
    PickImageFromGallery event,
    Emitter<ChalanState> emit,
  ) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    if (state is ChalanLoaded) {
      emit((state as ChalanLoaded).copyWith(selectedImage: imageFile));
    } else {
      emit((state as ChalanLoaded).copyWith(selectedImage: imageFile));
    }
  }

  void _onRemoveImage(RemoveImage event, Emitter<ChalanState> emit) {
    if (state is ChalanLoaded) {
      emit((state as ChalanLoaded).copyWith(selectedImage: null));
    }
  }

  Future<void> _onPickChalanDate(
    PickChalanDate event,
    Emitter<ChalanState> emit,
  ) async {
    final picked = await showDatePicker(
      context: event.context,
      initialDate: event.initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && state is ChalanLoaded) {
      emit((state as ChalanLoaded).copyWith(selectedDate: picked));
    }
  }
}
