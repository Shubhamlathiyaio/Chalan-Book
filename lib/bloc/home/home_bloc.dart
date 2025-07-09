import 'package:chalan_book_app/bloc/home/home_event.dart';
import 'package:chalan_book_app/bloc/home/home_state.dart';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    
    on<LoadOrganizations>(_onLoadOrganizations);
  }

  Future<void> _onLoadOrganizations(
    LoadOrganizations event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await supabase
          .from(organizationUsersTable)
          .select('organization_id, organizations:organization_id(*)')
          .eq('user_id', user.id);

      final orgs = response
          .where((row) => row['organizations'] != null)
          .map<Organization>(
            (row) => Organization.fromJson(row['organizations']),
          )
          .toList();

      if (orgs.isEmpty) {
        emit(HomeError('No organizations found.'));
        return;
      } 

      emit(
        HomeLoaded(
          organizations: orgs,
          currentOrganization: event.org ?? orgs.first,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load organizations: $e'));
    }
  }
}
