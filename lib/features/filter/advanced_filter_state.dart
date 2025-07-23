// import '../../../core/models/chalan.dart';
// import 'advanced_filter_model.dart';

// /// Base class for all advanced filter states
// abstract class AdvancedChalanFilterState {
//   final AdvancedChalanFilter filter;
//   final List<Chalan> originalChalans;
//   final List<Chalan> filteredChalans;
//   final bool isLoading;

//   const AdvancedChalanFilterState({
//     required this.filter,
//     required this.originalChalans,
//     required this.filteredChalans,
//     this.isLoading = false,
//   });
// }

// /// Initial state
// class AdvancedChalanFilterInitialState extends AdvancedChalanFilterState {
//   const AdvancedChalanFilterInitialState()
//       : super(
//           filter: const AdvancedChalanFilter(),
//           originalChalans: const [],
//           filteredChalans: const [],
//         );
// }

// /// Loading state
// class AdvancedChalanFilterLoadingState extends AdvancedChalanFilterState {
//   const AdvancedChalanFilterLoadingState({
//     required super.filter,
//     required super.originalChalans,
//     required super.filteredChalans,
//   }) : super(isLoading: true);
// }

// /// Applied state
// class AdvancedChalanFilterAppliedState extends AdvancedChalanFilterState {
//   const AdvancedChalanFilterAppliedState({
//     required super.filter,
//     required super.originalChalans,
//     required super.filteredChalans,
//   });
// }

// /// Error state
// class AdvancedChalanFilterErrorState extends AdvancedChalanFilterState {
//   final String message;

//   const AdvancedChalanFilterErrorState({
//     required this.message,
//     required super.filter,
//     required super.originalChalans,
//     required super.filteredChalans,
//   });
// }
