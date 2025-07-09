// nav_bar_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class NavBarCubit extends Cubit<int> {
  NavBarCubit() : super(0);

  void updateTab(int index) => emit(index);
}
