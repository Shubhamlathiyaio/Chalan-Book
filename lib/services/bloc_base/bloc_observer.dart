// app_bloc_observer.dart
import 'package:bloc/bloc.dart';
import 'dart:developer'; // Import for the log function

/// Custom [BlocObserver] that observes all bloc and cubit state changes, events,
/// errors, transitions, creations, and closings.
class AppBlocObserver extends BlocObserver {
  /// {@macro app_bloc_observer}
  const AppBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    log('onCreate -- ${bloc.runtimeType}'); // Log when a Bloc or Cubit is created
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent -- ${bloc.runtimeType}, $event'); // Log when an event is added to a Bloc
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange -- ${bloc.runtimeType}, $change'); // Log state changes (for both Blocs and Cubits)
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log('onTransition -- ${bloc.runtimeType}, $transition'); // Log transitions (for Blocs only)
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('onError -- ${bloc.runtimeType}, $error, $stackTrace'); // Log errors occurring within Blocs or Cubits
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    log('onClose -- ${bloc.runtimeType}'); // Log when a Bloc or Cubit is closed
  }
}
