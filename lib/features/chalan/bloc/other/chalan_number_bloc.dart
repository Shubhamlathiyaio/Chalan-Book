// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/models/chalan.dart';

// // Events
// abstract class ChalanNumberEvent {}

// class LoadMissingChalanNumbers extends ChalanNumberEvent {
//   final List<Chalan> existingChalans;
//   LoadMissingChalanNumbers(this.existingChalans);
// }

// class SelectChalanNumber extends ChalanNumberEvent {
//   final int selectedNumber;
//   SelectChalanNumber(this.selectedNumber);
// }

// class ClearSelectedNumber extends ChalanNumberEvent {}

// // States
// abstract class ChalanNumberState {}

// class ChalanNumberInitial extends ChalanNumberState {}

// class ChalanNumberLoaded extends ChalanNumberState {
//   final List<int> missingNumbers;
//   final int? selectedNumber;
//   final int nextAvailableNumber;

//   ChalanNumberLoaded({
//     required this.missingNumbers,
//     this.selectedNumber,
//     required this.nextAvailableNumber,
//   });
// }

// // BLoC
// class ChalanNumberBloc extends Bloc<ChalanNumberEvent, ChalanNumberState> {
//   ChalanNumberBloc() : super(ChalanNumberInitial()) {
//     on<LoadMissingChalanNumbers>(_onLoadMissingNumbers);
//     on<SelectChalanNumber>(_onSelectNumber);
//     on<ClearSelectedNumber>(_onClearSelectedNumber);
//   }

//   void _onLoadMissingNumbers(
//     LoadMissingChalanNumbers event,
//     Emitter<ChalanNumberState> emit,
//   ) {
//     final existingNumbers = event.existingChalans
//         .map((chalan) => int.tryParse(chalan.chalanNumber) ?? 0)
//         .where((num) => num > 0)
//         .toSet();

//     if (existingNumbers.isEmpty) {
//       emit(ChalanNumberLoaded(
//         missingNumbers: [],
//         nextAvailableNumber: 1,
//       ));
//       return;
//     }

//     final maxNumber = existingNumbers.reduce((a, b) => a > b ? a : b);
//     final missingNumbers = <int>[];

//     // Find missing numbers from 1 to maxNumber
//     for (int i = 1; i <= maxNumber; i++) {
//       if (!existingNumbers.contains(i)) {
//         missingNumbers.add(i);
//       }
//     }

//     // Next available number is either the first missing number or maxNumber + 1
//     final nextAvailable = missingNumbers.isNotEmpty 
//         ? missingNumbers.first 
//         : maxNumber + 1;

//     emit(ChalanNumberLoaded(
//       missingNumbers: missingNumbers,
//       nextAvailableNumber: nextAvailable,
//     ));
//   }

//   void _onSelectNumber(
//     SelectChalanNumber event,
//     Emitter<ChalanNumberState> emit,
//   ) {
//     if (state is ChalanNumberLoaded) {
//       final currentState = state as ChalanNumberLoaded;
//       emit(ChalanNumberLoaded(
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: event.selectedNumber,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }

//   void _onClearSelectedNumber(
//     ClearSelectedNumber event,
//     Emitter<ChalanNumberState> emit,
//   ) {
//     if (state is ChalanNumberLoaded) {
//       final currentState = state as ChalanNumberLoaded;
//       emit(ChalanNumberLoaded(
//         missingNumbers: currentState.missingNumbers,
//         selectedNumber: null,
//         nextAvailableNumber: currentState.nextAvailableNumber,
//       ));
//     }
//   }
// }
