// import 'package:chalan_book_app/features/filter/advanced_filter_bloc.dart';
// import 'package:chalan_book_app/features/filter/advanced_filter_event.dart';
// import 'package:chalan_book_app/features/organization/bloc/organization_bloc.dart';
// import 'package:chalan_book_app/features/shared/widgets/empty_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../core/models/chalan.dart';
// import '../../../core/models/organization.dart';
// import '../bloc/chalan_bloc.dart';
// import '../bloc/chalan_filter_bloc.dart';
// import '../widgets/chalan_filter_widget.dart';
// import 'add_chalan_page.dart';

// /// Updated Chalan List Page with comprehensive filtering
// class ChalanListPageWithFilters extends StatelessWidget {
//   final Organization? organization;

//   const ChalanListPageWithFilters({super.key, required this.organization});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) =>
//               ChalanBloc(organizationBloc: context.read<OrganizationBloc>()),
//         ),
//         BlocProvider(create: (context) => ChalanFilterBloc()),
//       ],
//       child: ChalanListViewWithFilters(organization: organization),
//     );
//   }
// }

// /// Main view with filters
// class ChalanListViewWithFilters extends StatefulWidget {
//   final Organization? organization;

//   const ChalanListViewWithFilters({super.key, required this.organization});

//   @override
//   State<ChalanListViewWithFilters> createState() =>
//       _ChalanListViewWithFiltersState();
// }

// class _ChalanListViewWithFiltersState extends State<ChalanListViewWithFilters> {
//   @override
//   void initState() {
//     super.initState();
//     _loadChalans();
//   }

//   @override
//   void didUpdateWidget(ChalanListViewWithFilters oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.organization?.id != widget.organization?.id) {
//       _loadChalans();
//     }
//   }

//   void _loadChalans() {
//     if (widget.organization != null) {
//       context.read<ChalanBloc>().add(LoadChalansEvent(widget.organization!));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.organization == null) {
//       return EmptyState(
//         icon: Icons.business,
//         title: 'No Organization Selected',
//         subtitle: 'Please select or create an organization first',
//         actionText: 'Go to Organizations',
//         onAction: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Go to the Organizations tab')),
//           );
//         },
//       );
//     }

//     return BlocListener<ChalanBloc, ChalanState>(
//       listener: (context, state) {
//         // Update filter bloc when chalans are loaded
//         if (state is ChalanLoadedState ||
//             state is ChalanOperationSuccessState) {
//           final chalans = state is ChalanLoadedState
//               ? state.chalans
//               : (state as ChalanOperationSuccessState).chalans;

//           context.read<ChalanFilterBloc>().updateOriginalChalans(chalans);
//         }

//         // Show error/success messages
//         if (state is ChalanErrorState) {
//           _showSnackBar(state.message, isError: true);
//         } else if (state is ChalanOperationSuccessState) {
//           _showSnackBar(state.message);
//         }
//       },
//       child: Scaffold(
//         body: Column(
//           children: [
//             // Header with organization info
//             _buildHeader(context),

//             // Filter widget
//             const ChalanFilterWidget(),

//             // Chalan list
//             Expanded(
//               child: BlocBuilder<ChalanFilterBloc, ChalanFilterState>(
//                 builder: (context, filterState) {
//                   return BlocBuilder<ChalanBloc, ChalanState>(
//                     builder: (context, chalanState) {
//                       return _buildBody(context, chalanState, filterState);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: _buildFloatingActionButton(context),
//       ),
//     );
//   }

//   /// Build header with organization info
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10.r,
//             offset: Offset(0, 2.h),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(Icons.receipt_long, color: Colors.blue, size: 24.w),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.organization?.name ?? 'Chalans',
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 SizedBox(height: 2.h),
//                 BlocBuilder<ChalanFilterBloc, ChalanFilterState>(
//                   builder: (context, state) {
//                     final count = state.filteredChalans.length;
//                     final total = state.originalChalans.length;

//                     return Text(
//                       count == total
//                           ? '$count ${count == 1 ? 'chalan' : 'chalans'}'
//                           : '$count of $total chalans',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: Colors.grey[600],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Build main body content
//   Widget _buildBody(
//     BuildContext context,
//     ChalanState chalanState,
//     ChalanFilterState filterState,
//   ) {
//     // Show loading state
//     if (chalanState is ChalanInitialState ||
//         chalanState is ChalanLoadingState) {
//       return LoadingWidget(
//         message: 'Loading your chalans...',
//         showLogo: true,
//         height: 400.h,
//       );
//     }

//     // Show error state
//     if (chalanState is ChalanErrorState) {
//       return _buildErrorState(chalanState.message);
//     }

//     // Show empty state for no chalans
//     if (chalanState is ChalanEmptyState) {
//       return EmptyState(
//         icon: Icons.receipt_long,
//         title: 'No Chalans Found',
//         subtitle: 'Add your first chalan to get started',
//         actionText: 'Add Chalan',
//         onAction: () => _navigateToAddChalan(context),
//       );
//     }

//     // Show filtered results
//     final chalansToShow = filterState.filteredChalans;

//     if (chalansToShow.isEmpty && filterState.filter.isActive) {
//       return EmptyState(
//         icon: Icons.filter_list_off,
//         title: 'No Results Found',
//         subtitle: 'Try adjusting your filters or search terms',
//         actionText: 'Clear Filters',
//         onAction: () {
//           context.read<AdvancedChalanFilterBloc>().add(ClearAllFiltersEvent());
//         },
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         context.read<ChalanBloc>().add(
//           RefreshChalansEvent(widget.organization!),
//         );
//       },
//       color: Colors.blue,
//       child: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         itemCount: chalansToShow.length,
//         itemBuilder: (context, index) {
//           final chalan = chalansToShow[index];
//           return _buildChalanCard(context, chalan, index);
//         },
//       ),
//     );
//   }

//   /// Build error state widget
//   Widget _buildErrorState(String message) {
//     return Center(
//       child: Container(
//         margin: EdgeInsets.all(24.w),
//         padding: EdgeInsets.all(24.w),
//         decoration: BoxDecoration(
//           color: Colors.red[50],
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: Colors.red[200]!),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline, size: 64.w, color: Colors.red[400]),
//             SizedBox(height: 16.h),
//             Text(
//               'Oops! Something went wrong',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red[700],
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
//             ),
//             SizedBox(height: 24.h),
//             ElevatedButton.icon(
//               onPressed: _loadChalans,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red[600],
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Build individual chalan card with creator info
//   Widget _buildChalanCard(BuildContext context, Chalan chalan, int index) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 300 + (index * 100)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 50 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: Card(
//               margin: EdgeInsets.only(bottom: 12.h),
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//               child: InkWell(
//                 onTap: () => _navigateToChalanDetail(context, chalan),
//                 borderRadius: BorderRadius.circular(16.r),
//                 child: Padding(
//                   padding: EdgeInsets.all(16.w),
//                   child: Row(
//                     children: [
//                       _buildChalanImage(chalan),
//                       SizedBox(width: 16.w),
//                       Expanded(child: _buildChalanInfo(chalan)),
//                       _buildChalanMenu(context, chalan),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Build chalan image
//   Widget _buildChalanImage(Chalan chalan) {
//     return Hero(
//       tag: 'chalan_image_${chalan.id}',
//       child: Container(
//         width: 60.w,
//         height: 60.h,
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: chalan.imageUrl != null
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: Image.network(
//                   chalan.imageUrl!,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(
//                       child: SizedBox(
//                         width: 20.w,
//                         height: 20.h,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           value: loadingProgress.expectedTotalBytes != null
//                               ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes!
//                               : null,
//                         ),
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Icon(
//                       Icons.receipt_long,
//                       color: Colors.blue,
//                       size: 24.w,
//                     );
//                   },
//                 ),
//               )
//             : Icon(Icons.receipt_long, color: Colors.blue, size: 24.w),
//       ),
//     );
//   }

//   /// Build chalan info with creator details
//   Widget _buildChalanInfo(Chalan chalan) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Chalan number and creator info
//         Row(
//           children: [
//             Text(
//               chalan.chalanNumber,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const Spacer(),
//             // Creator badge
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//               decoration: BoxDecoration(
//                 color: _getCreatorColor(chalan.createdBy).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Text(
//                 _getCreatorRole(chalan.createdBy),
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   color: _getCreatorColor(chalan.createdBy),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         SizedBox(height: 4.h),

//         // Description
//         if (chalan.description != null && chalan.description!.isNotEmpty)
//           Text(
//             chalan.description!,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//           ),

//         SizedBox(height: 8.h),

//         // Date
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//           decoration: BoxDecoration(
//             color: Colors.blue.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Text(
//             _formatDate(chalan.dateTime),
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: Colors.blue[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Build chalan menu
//   Widget _buildChalanMenu(BuildContext context, Chalan chalan) {
//     return PopupMenuButton<String>(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'view',
//           child: Row(
//             children: [
//               Icon(Icons.visibility, color: Colors.blue, size: 20.w),
//               SizedBox(width: 12.w),
//               const Text('View'),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'edit',
//           child: Row(
//             children: [
//               Icon(Icons.edit, color: Colors.orange, size: 20.w),
//               SizedBox(width: 12.w),
//               const Text('Edit'),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'delete',
//           child: Row(
//             children: [
//               Icon(Icons.delete, color: Colors.red, size: 20.w),
//               SizedBox(width: 12.w),
//               const Text('Delete', style: TextStyle(color: Colors.red)),
//             ],
//           ),
//         ),
//       ],
//       onSelected: (value) {
//         switch (value) {
//           case 'view':
//             _navigateToChalanDetail(context, chalan);
//             break;
//           case 'edit':
//             _navigateToEditChalan(context, chalan);
//             break;
//           case 'delete':
//             _showDeleteConfirmation(chalan);
//             break;
//         }
//       },
//     );
//   }

//   /// Build floating action button
//   Widget _buildFloatingActionButton(BuildContext context) {
//     return BlocBuilder<ChalanBloc, ChalanState>(
//       builder: (context, state) {
//         // Hide FAB during loading
//         if (state is ChalanLoadingState) {
//           return const SizedBox.shrink();
//         }

//         return FloatingActionButton.extended(
//           onPressed: () => _navigateToAddChalan(context),
//           icon: const Icon(Icons.add),
//           label: const Text('Add Chalan'),
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//         );
//       },
//     );
//   }

//   /// Get creator role display text
//   String _getCreatorRole(String? createdBy) {
//     if (createdBy == null) return 'Unknown';

//     // Check if current user
//     final currentUserId = supabase.auth.currentUser?.id;
//     if (createdBy == currentUserId) return 'Me';

//     // Check organization role (you might want to fetch this from database)
//     // For now, return generic role
//     return 'Member';
//   }

//   /// Get creator role color
//   Color _getCreatorColor(String? createdBy) {
//     if (createdBy == null) return Colors.grey;

//     final currentUserId = supabase.auth.currentUser?.id;
//     if (createdBy == currentUserId) return Colors.green;

//     return Colors.blue;
//   }

//   /// Navigation methods
//   void _navigateToAddChalan(BuildContext context) async {
//     final chalans = context.read<ChalanFilterBloc>().state.originalChalans;
//     final max = chalans.isNotEmpty
//         ? chalans
//               .map((c) => int.tryParse(c.chalanNumber) ?? 0)
//               .reduce((a, b) => a > b ? a : b)
//         : 0;

//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddChalanPage(
//           organization: widget.organization!,
//           nextChalanNumber: max + 1,
//         ),
//       ),
//     );

//     if (result == true) {
//       context.read<ChalanBloc>().add(RefreshChalansEvent(widget.organization!));
//     }
//   }

//   void _navigateToEditChalan(BuildContext context, Chalan chalan) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//             AddChalanPage(organization: widget.organization!, chalan: chalan),
//       ),
//     );

//     if (result == true) {
//       context.read<ChalanBloc>().add(RefreshChalansEvent(widget.organization!));
//     }
//   }

//   void _navigateToChalanDetail(BuildContext context, Chalan chalan) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => ChalanDetailPage(chalan: chalan)),
//     );
//   }

//   /// Show delete confirmation dialog
//   Future<void> _showDeleteConfirmation(Chalan chalan) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.w),
//             SizedBox(width: 12.w),
//             const Text('Delete Chalan'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Are you sure you want to delete this chalan?'),
//             SizedBox(height: 12.h),
//             Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.receipt_long, color: Colors.blue, size: 20.w),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     child: Text(
//                       chalan.chalanNumber,
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'This action cannot be undone.',
//               style: TextStyle(color: Colors.red[600], fontSize: 12.sp),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       context.read<ChalanBloc>().add(DeleteChalanEvent(chalan));
//     }
//   }

//   /// Show snackbar message
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isError ? Icons.error_outline : Icons.check_circle_outline,
//               color: Colors.white,
//               size: 20.w,
//             ),
//             SizedBox(width: 12.w),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: isError ? Colors.red[600] : Colors.green[600],
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.all(16.w),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         duration: Duration(seconds: isError ? 4 : 2),
//       ),
//     );
//   }

//   /// Format date helper
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
