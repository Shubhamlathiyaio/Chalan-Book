import 'dart:async';
import 'package:chalan_book_app/bloc/organization/organization_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/models/chalan.dart';
import '../../../main.dart';
import 'chalan_event.dart';
import 'chalan_state.dart';

class ChalanBloc extends Bloc<ChalanEvent, ChalanState> {
  final OrganizationBloc organizationBloc;
  StreamSubscription? _organizationSubscription;

  ChalanBloc({required this.organizationBloc}) : super(ChalanInitialState()) {
    // ✅ Register event handlers FIRST
    on<LoadChalansEvent>(_onLoadChalans);
    on<AddChalanEvent>(_onAddChalan);
    on<UpdateChalanEvent>(_onUpdateChalan);
    on<DeleteChalanEvent>(_onDeleteChalan);
    on<RefreshChalansEvent>(_onRefreshChalans);
    
    // ✅ THEN set up organization listening
    _initializeOrganizationListener();
  }

  void _initializeOrganizationListener() {
    // Listen to organization changes
    _organizationSubscription = organizationBloc.stream.listen((orgState) {
      if (orgState.currentOrg != null) {
        add(LoadChalansEvent(orgState.currentOrg!));
      }
    });

    // Load initial data if organization is already selected
    if (organizationBloc.state.currentOrg != null) {
      add(LoadChalansEvent(organizationBloc.state.currentOrg!));
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
    emit(ChalanLoadingState());
    
    try {
      final response = await supabase
          .from(chalansTable)
          .select()
          .eq('organization_id', event.organization.id)
          .order('date_time', ascending: false);

      final chalans = response.map((e) => Chalan.fromJson(e)).toList();
      
      if (chalans.isEmpty) {
        emit(ChalanEmptyState());
      } else {
        emit(ChalanLoadedState(chalans));
      }
    } catch (e) {
      emit(ChalanErrorState('Error loading chalans: $e'));
    }
  }

  Future<void> _onAddChalan(
    AddChalanEvent event,
    Emitter<ChalanState> emit,
  ) async {
    try {
      await supabase.from(chalansTable).insert(event.chalan.toJson());
      
      if (state is ChalanLoadedState) {
        final currentChalans = List<Chalan>.from((state as ChalanLoadedState).chalans);
        currentChalans.insert(0, event.chalan);
        emit(ChalanOperationSuccessState('Chalan added successfully!', currentChalans));
      } else {
        emit(ChalanOperationSuccessState('Chalan added successfully!', [event.chalan]));
      }
    } catch (e) {
      emit(ChalanErrorState('Error adding chalan: $e'));
    }
  }

  Future<void> _onUpdateChalan(
    UpdateChalanEvent event,
    Emitter<ChalanState> emit,
  ) async {
    try {
      await supabase
          .from(chalansTable)
          .update(event.chalan.toJson())
          .eq('id', event.chalan.id);
      
      if (state is ChalanLoadedState) {
        final currentChalans = List<Chalan>.from((state as ChalanLoadedState).chalans);
        final index = currentChalans.indexWhere((c) => c.id == event.chalan.id);
        if (index != -1) {
          currentChalans[index] = event.chalan;
          emit(ChalanOperationSuccessState('Chalan updated successfully!', currentChalans));
        }
      }
    } catch (e) {
      emit(ChalanErrorState('Error updating chalan: $e'));
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
        await supabase.storage.from(chalanImagesBucket).remove([fileName]);
      }

      await supabase.from(chalansTable).delete().eq('id', event.chalan.id);
      
      if (state is ChalanLoadedState) {
        final currentChalans = List<Chalan>.from((state as ChalanLoadedState).chalans);
        currentChalans.removeWhere((c) => c.id == event.chalan.id);
        
        if (currentChalans.isEmpty) {
          emit(ChalanEmptyState());
        } else {
          emit(ChalanOperationSuccessState('Chalan deleted successfully!', currentChalans));
        }
      }
    } catch (e) {
      emit(ChalanErrorState('Error deleting chalan: $e'));
    }
  }

  Future<void> _onRefreshChalans(
    RefreshChalansEvent event,
    Emitter<ChalanState> emit,
  ) async {
    try {
      final response = await supabase
          .from(chalansTable)
          .select()
          .eq('organization_id', event.organization.id)
          .order('date_time', ascending: false);

      final chalans = response.map((e) => Chalan.fromJson(e)).toList();
      
      if (chalans.isEmpty) {
        emit(ChalanEmptyState());
      } else {
        emit(ChalanLoadedState(chalans));
      }
    } catch (e) {
      emit(ChalanErrorState('Error refreshing chalans: $e'));
    }
  }

  @override
  void onChange(Change<ChalanState> change) {
    super.onChange(change);
    print('ChalanBloc change: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onTransition(Transition<ChalanEvent, ChalanState> transition) {
    print('ChalanBloc transition: ${transition.event.runtimeType}');
    super.onTransition(transition);
  }
}