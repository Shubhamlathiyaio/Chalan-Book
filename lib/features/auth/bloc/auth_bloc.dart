import 'package:chalan_book_app/features/auth/bloc/auth_event.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_state.dart';
import 'package:chalan_book_app/services/auth_services.dart';
import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Supa supa = Supa();
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_login);
    on<AuthSignupRequested>(_signup);
  }

  Future<void> _login(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await AuthService().login(
        email: event.email,
        password: event.password,
      ); //                      The getter 'user' isn't defined for the type 'Map<String, dynamic>'. Try importing the library that defines 'user' , correcting the name to t e name o an existing getter, or defining a getter or field named 'user'.
      final user = res['user'];
      if (user == null) throw const AuthException('Login failed');

      // Invite logic removed

      emit(AuthSuccess());
    } on AuthException catch (e) {
      print("Auth error: ${e.message}");
      emit(AuthFailure(e.message));
    } catch (e) {
      print("Unexpected error: $e");
      emit(AuthFailure('Unexpected error'));
    }
  }

  Future<void> _signup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final res = await AuthService().signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      if (res['user'] == null) throw const AuthException('Signup failed');
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

  // @override
  // void onTransition(Transition<AuthEvent, AuthState> transition) {
  //   print('AuthBloc transition: $transition');
  //   super.onTransition(transition);
  // }
}
