

import 'package:chalan_book_app/bloc/auth/auth_event.dart';
import 'package:chalan_book_app/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:uuid/uuid.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_login);
    on<AuthSignupRequested>(_signup);
  }

  final _supabase = Supabase.instance.client;

  Future<void> _login(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      final user = res.user;
      if (user == null) throw const AuthException('Login failed');

      // Auto‑link invites
      final email = user.email!.toLowerCase();
      final invites = await _supabase
          .from('organization_invites')
          .select('id, organization_id')
          .eq('email', email) as List<dynamic>;

      for (final inv in invites) {
        await _supabase.from('organization_users').upsert({
          'id': const Uuid().v4(),
          'organization_id': inv['organization_id'],
          'user_id': user.id,
          'email': email,
          'role': 'member',
        });
      }
      if (invites.isNotEmpty) {
        final ids = invites.map((i) => i['id']).toList();
        await _supabase.from('organization_invites').delete().inFilter('id', ids);
      }

      emit(AuthSuccess());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Unexpected error'));
    }
  }

  Future<void> _signup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _supabase.auth.signUp(
        email: event.email,
        password: event.password,
      );
      if (res.user == null) throw const AuthException('Signup failed');
      emit(AuthSuccess());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Unexpected error'));
    }
  }

  
  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    print('AuthBloc change: $change');
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    print('AuthBloc transition: $transition');
    super.onTransition(transition);
  }
}
