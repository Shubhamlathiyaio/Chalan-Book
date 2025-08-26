// Event
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileEvent {}

class ProfileLoaded extends ProfileEvent {
  final User user;
  ProfileLoaded(this.user);
}

class ToggleEditingEvent extends ProfileEvent {}

// Event to create profile with name
class CreateProfileRequested extends ProfileEvent {
  final String name;
  CreateProfileRequested(this.name);
}

// State

abstract class ProfileState {}

class LoadedProfileState extends ProfileState {
  final bool isEditing;
  LoadedProfileState({this.isEditing = false});

  LoadedProfileState copyWith({bool? isEditing}) {
    return LoadedProfileState(isEditing: isEditing ?? this.isEditing);
  }
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final String userName;
  ProfileSuccess(this.userName);
}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure(this.error);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<ToggleEditingEvent>(_onToggleEditing);
    on<CreateProfileRequested>(_onCreateProfile);
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileSuccess('')); // You can update with user data
  }

  Future<void> _onToggleEditing(
    ToggleEditingEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is LoadedProfileState) {
      emit(
        (state as LoadedProfileState).copyWith(
          isEditing: !(state as LoadedProfileState).isEditing,
        ),
      );
    }
  }

  Future<void> _onCreateProfile(
    CreateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      emit(ProfileFailure('No authenticated user'));
      return;
    }

    try {
      await Supabase.instance.client.from(AppKeys.profilesTable).insert({
        'id': user.id,
        'name': event.name,
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
      });

      emit(ProfileSuccess(event.name));
    } catch (e) {
      emit(ProfileFailure('Failed to create profile: $e'));
    }
  }
}
