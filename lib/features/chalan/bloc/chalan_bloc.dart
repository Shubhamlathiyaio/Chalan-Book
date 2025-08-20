import 'dart:async';
import 'dart:io';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/models/chalan.dart';
import '../../../main.dart';
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

class ShowChalanLoading extends ChalanEvent {}

class DeleteChalanEvent extends ChalanEvent {
  final Chalan chalan;
  DeleteChalanEvent(this.chalan);
}

class RefreshChalansEvent extends ChalanEvent {
  final Organization organization;
  RefreshChalansEvent(this.organization);
}

class SelectChalanNumberEvent extends ChalanEvent {
  final int selectedNumber;
  SelectChalanNumberEvent(this.selectedNumber);
}

class ClearSelectedChalanNumberEvent extends ChalanEvent {}

class ClearSelectedNumber extends ChalanEvent {}

class LoadMissingChalanNumbers extends ChalanEvent {
  final List<Chalan> existingChalans;
  LoadMissingChalanNumbers(this.existingChalans);
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
  final List<int> missingNumbers;
  final int nextAvailableNumber;
  final int? selectedNumber;
  final File? selectedImage;
  final DateTime selectedDate;

  ChalanLoaded({
    required this.chalans,
    required this.missingNumbers,
    required this.nextAvailableNumber,
    this.selectedNumber,
    this.selectedImage,
    required this.selectedDate,
  });
}

class ChalanEmpty extends ChalanState {}

class ChalanError extends ChalanState {
  final String message;
  ChalanError(this.message);
}

class ChalanOperationSuccess extends ChalanState {
  final String message;
  final List<Chalan> chalans;
  final List<int> missingNumbers;
  final int nextAvailableNumber;
  final int? selectedNumber;
  final File? selectedImage;
  final DateTime selectedDate;

  ChalanOperationSuccess(
    this.message,
    this.chalans, {
    required this.missingNumbers,
    required this.nextAvailableNumber,
    this.selectedNumber,
    this.selectedImage,
    required this.selectedDate,
  });
}

// ################################################################################
// #                                     BLOC                                     #
// ################################################################################
class ChalanBloc extends Bloc<ChalanEvent, ChalanState> {
  final OrganizationBloc organizationBloc;
  final supa = Supa();
  StreamSubscription? _organizationSubscription;

  ChalanBloc({required this.organizationBloc}) : super(ChalanInitial()) {
    on<LoadChalansEvent>(_onLoadChalans);
    on<AddChalanEvent>(_onAddChalan);
    on<UpdateChalanEvent>(_onUpdateChalan);
    on<DeleteChalanEvent>(_onDeleteChalan);
    on<RefreshChalansEvent>(_onRefreshChalans);
    on<SelectChalanNumberEvent>(_onSelectChalanNumber);
    on<ClearSelectedChalanNumberEvent>(_onClearSelectedNumber);
    on<LoadMissingChalanNumbers>(_onLoadMissingChalanNumbers);
    on<PickImageFromCamera>(_onPickImageFromCamera);
    on<PickImageFromGallery>(_onPickImageFromGallery);
    on<RemoveImage>(_onRemoveImage);
    on<PickChalanDate>(_onPickChalanDate);

    _initializeOrganizationListener();
  }

  void _initializeOrganizationListener() {
    _organizationSubscription = organizationBloc.stream.listen((orgState) {
      if (orgState is OrganizationLoaded && orgState.currentOrg != null) {
        add(LoadChalansEvent(orgState.currentOrg!));
      }
    });

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

  List<int> _calculateMissingNumbers(List<Chalan> chalans) {
    final numbers = chalans
        .map((c) => int.tryParse(c.chalanNumber) ?? 0)
        .where((n) => n > 0)
        .toSet();

    if (numbers.isEmpty) return [];

    final maxNumber = numbers.reduce((a, b) => a > b ? a : b);
    return [
      for (int i = 1; i <= maxNumber; i++)
        if (!numbers.contains(i)) i,
    ];
  }

  int _getNextAvailableNumber(List<int> missingNumbers, List<Chalan> chalans) {
    if (missingNumbers.isNotEmpty) return missingNumbers.first;
    final numbers = chalans
        .map((c) => int.tryParse(c.chalanNumber) ?? 0)
        .where((n) => n > 0);
    final max = numbers.isNotEmpty
        ? numbers.reduce((a, b) => a > b ? a : b)
        : 0;
    return max + 1;
  }

  Future<void> _onLoadChalans(
    LoadChalansEvent event,
    Emitter<ChalanState> emit,
  ) async {
    emit(ChalanLoading());

    try {
      final response = await supa
          .from(AppKeys.chalansTable)
          .select()
          .eq('organization_id', event.organization.id)
          .order('chalan_number', ascending: true);

      final chalans = response.map((e) => Chalan.fromJson(e)).toList();

      if (chalans.isEmpty) {
        emit(ChalanEmpty());
        return;
      }

      // 🔄 Optional: Validate Mega URLs (remove invalid ones)
      final validChalans = chalans.where((chalan) {
        return chalan.imageUrl == null ||
            chalan.imageUrl!.contains('mega.nz') ||
            chalan.imageUrl!.contains('mega.co.nz');
      }).toList();

      final missing = _calculateMissingNumbers(validChalans);
      final next = _getNextAvailableNumber(missing, validChalans);

      emit(
        ChalanLoaded(
          chalans: validChalans,
          missingNumbers: missing,
          nextAvailableNumber: next,
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
      // Insert the chalan
      await supa.from(AppKeys.chalansTable).insert(event.chalan.toJson());

      // Reload all chalans from database to get fresh data
      final response = await supa
          .from(AppKeys.chalansTable)
          .select()
          .eq('organization_id', event.chalan.organizationId)
          .order('chalan_number', ascending: true);

      final chalans = response.map((e) => Chalan.fromJson(e)).toList();

      final missing = _calculateMissingNumbers(chalans);
      final next = _getNextAvailableNumber(missing, chalans);

      emit(
        ChalanLoaded(
          chalans: chalans,
          missingNumbers: missing,
          nextAvailableNumber: next,
          selectedNumber: null,
          selectedImage: null,
          selectedDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(ChalanError('Error adding chalan: $e'));
    }
  }

  void _onUpdateChalanDate(UpdateChalanDate event, Emitter<ChalanState> emit) {
    if (state is ChalanLoaded) {
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: current.selectedNumber,
          selectedImage: current.selectedImage,
          selectedDate: event.date,
        ),
      );
    }
  }

  Future<void> _onUpdateChalan(
    UpdateChalanEvent event,
    Emitter<ChalanState> emit,
  ) async {
    try {
      await supa
          .from(AppKeys.chalansTable)
          .update(event.chalan.toJson())
          .eq('id', event.chalan.id);

      if (state is ChalanLoaded) {
        final current = (state as ChalanLoaded);
        final updated = List<Chalan>.from(current.chalans);
        final index = updated.indexWhere((c) => c.id == event.chalan.id);
        if (index != -1) {
          updated[index] = event.chalan;

          final missing = _calculateMissingNumbers(updated);
          final next = _getNextAvailableNumber(missing, updated);

          emit(
            ChalanOperationSuccess(
              'Chalan updated successfully!',
              updated,
              missingNumbers: missing,
              nextAvailableNumber: next,
              selectedNumber: current.selectedNumber,
              selectedImage: current.selectedImage,
              selectedDate: current.selectedDate,
            ),
          );
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
      if (event.chalan.imageUrl != null) {
        final uri = Uri.parse(event.chalan.imageUrl!);
        final fileName = uri.pathSegments.last;
        await supa.storage.from(AppKeys.chalanImagesBucket).remove([
          fileName,
        ]);
      }

      await supa
          .from(AppKeys.chalansTable)
          .delete()
          .eq('id', event.chalan.id);

      if (state is ChalanLoaded) {
        final current = (state as ChalanLoaded);
        final updated = List<Chalan>.from(current.chalans)
          ..removeWhere((c) => c.id == event.chalan.id);

        if (updated.isEmpty) {
          emit(ChalanEmpty());
        } else {
          final missing = _calculateMissingNumbers(updated);
          final next = _getNextAvailableNumber(missing, updated);

          emit(
            ChalanOperationSuccess(
              'Chalan deleted successfully!',
              updated,
              missingNumbers: missing,
              nextAvailableNumber: next,
              selectedNumber: current.selectedNumber,
              selectedImage: current.selectedImage,
              selectedDate: current.selectedDate,
            ),
          );
        }
      }
    } catch (e) {
      emit(ChalanError('Error deleting chalan: $e'));
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
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: event.selectedNumber,
          selectedImage: current.selectedImage,
          selectedDate: current.selectedDate,
        ),
      );
    }
  }

  void _onClearSelectedNumber(
    ClearSelectedChalanNumberEvent event,
    Emitter<ChalanState> emit,
  ) {
    if (state is ChalanLoaded) {
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: null,
          selectedImage: current.selectedImage,
          selectedDate: current.selectedDate,
        ),
      );
    }
  }

  _onLoadMissingChalanNumbers(
    LoadMissingChalanNumbers event,
    Emitter<ChalanState> emit,
  ) {
    final existingNumbers = event.existingChalans
        .map((chalan) => int.tryParse(chalan.chalanNumber) ?? 0)
        .where((num) => num > 0)
        .toSet();

    if (existingNumbers.isEmpty) {
      emit(
        ChalanLoaded(
          missingNumbers: [],
          nextAvailableNumber: 1,
          selectedNumber: null,
          chalans: event.existingChalans,
          selectedImage: null,
          selectedDate: DateTime.now(),
        ),
      );
      return;
    }

    final maxNumber = existingNumbers.reduce((a, b) => a > b ? a : b);
    final missingNumbers = [
      for (int i = 1; i <= maxNumber; i++)
        if (!existingNumbers.contains(i)) i,
    ];
    final nextAvailable = missingNumbers.isNotEmpty
        ? missingNumbers.first
        : maxNumber + 1;

    emit(
      ChalanLoaded(
        missingNumbers: missingNumbers,
        nextAvailableNumber: nextAvailable,
        selectedNumber: null,
        chalans: event.existingChalans,
        selectedImage: null,
        selectedDate: DateTime.now(),
      ),
    );
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
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: current.selectedNumber,
          selectedImage: imageFile, // ✅ Set the picked image
          selectedDate: current.selectedDate,
        ),
      );
    } else {
      // ✅ Handle case when state is not ChalanLoaded yet
      emit(
        ChalanLoaded(
          chalans: [],
          missingNumbers: [],
          nextAvailableNumber: 1,
          selectedNumber: null,
          selectedImage: imageFile, // ✅ Set the picked image
          selectedDate: DateTime.now(),
        ),
      );
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
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: current.selectedNumber,
          selectedImage: imageFile, // ✅ Set the picked image
          selectedDate: current.selectedDate,
        ),
      );
    } else {
      // ✅ Handle case when state is not ChalanLoaded yet
      emit(
        ChalanLoaded(
          chalans: [],
          missingNumbers: [],
          nextAvailableNumber: 1,
          selectedNumber: null,
          selectedImage: imageFile, // ✅ Set the picked image
          selectedDate: DateTime.now(),
        ),
      );
    }
  }

  void _onRemoveImage(RemoveImage event, Emitter<ChalanState> emit) {
    if (state is ChalanLoaded) {
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: current.selectedNumber,
          selectedImage: null,
          selectedDate: current.selectedDate,
        ),
      );
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
      final current = state as ChalanLoaded;
      emit(
        ChalanLoaded(
          chalans: current.chalans,
          missingNumbers: current.missingNumbers,
          nextAvailableNumber: current.nextAvailableNumber,
          selectedNumber: current.selectedNumber,
          selectedImage: current.selectedImage,
          selectedDate: picked,
        ),
      );
    }
  }
}
