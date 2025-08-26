import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:chalan_book_app/features/auth/bloc/auth_event.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_state.dart';
import 'package:chalan_book_app/services/auth_services.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_login);
    on<AuthSignupRequested>(_signup);
    on<AuthProfileRequested>(_createProfile);
  }

  Future<void> _login(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await AuthService().login(email: event.email, password: event.password);
      final user = res['user'];
      if (user == null) throw const AuthException('Login failed');

      // Check if profile exists
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthProfileSuccess());
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(AuthFailure('Unexpected error'));
    }
  }

  Future<void> _signup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await AuthService().signUp(email: event.email, password: event.password);

      if (res['success'] != true || res['userId'] == null) {
        throw const AuthException('Signup failed');
      }

      // Wait for email confirmation; no profile creation yet
      emit(AuthSuccess());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(AuthFailure('Unexpected error'));
    }
  }

  Future<void> _createProfile(AuthProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      emit(AuthFailure('No authenticated user found.'));
      return;
    }
    try {
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'name': event.name,
      });
      emit(AuthProfileSuccess());
    } catch (e) {
      emit(AuthFailure('Failed to create user profile.'));
    }
  }
}
