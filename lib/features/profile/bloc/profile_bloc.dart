// Event
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileEvent {}

class ProfileLoaded extends ProfileEvent {
  final User user;
  ProfileLoaded(this.user);
}

class ToggleEditingEvent extends ProfileEvent {}

// State
class ProfileState {
  final String userName;
  final bool isEditing;
  const ProfileState({this.userName = '', this.isEditing = false});

  ProfileState copyWith({String? userName, bool? isEditing}) {
    return ProfileState(
      userName: userName ?? this.userName,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<ToggleEditingEvent>(_onToggleEditing);
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    final user = event.user;
    emit(
      state.copyWith(
        // user: user,
      ),
    );
  }

  Future<void> _onToggleEditing(
    ToggleEditingEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isEditing: !state.isEditing));
  }
}
