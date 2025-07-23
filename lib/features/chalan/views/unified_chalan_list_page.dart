// import 'package:chalan_book_app/features/organization/views/chalan_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../core/extensions/context_extension.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../../../core/models/chalan.dart';
// import '../../../core/models/organization.dart';
// import '../../../main.dart';
// import '../../organization/bloc/organization_bloc.dart';
// import '../../shared/widgets/empty_state.dart';
// import '../../shared/widgets/loading.dart';
// import '../bloc/unified_chalan_bloc.dart';
// import '../views/add_chalan_page.dart';

// /// Unified Chalan List Page with comprehensive filtering and chalan number management
// class UnifiedChalanListPage extends StatelessWidget {
//   final Organization? organization;

//   const UnifiedChalanListPage({super.key, required this.organization});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           UnifiedChalanBloc(organizationBloc: context.read<OrganizationBloc>()),
//       child: UnifiedChalanListView(organization: organization),
//     );
//   }
// }

// /// Main view with unified filtering and chalan management
// class UnifiedChalanListView extends StatefulWidget {
//   final Organization? organization;

//   const UnifiedChalanListView({super.key, required this.organization});

//   @override
//   State<UnifiedChalanListView> createState() => _UnifiedChalanListViewState();
// }

// class _UnifiedChalanListViewState extends State<UnifiedChalanListView> {
//   @override
//   void initState() {
//     super.initState();
//     _loadChalans();
//   }

//   @override
//   void didUpdateWidget(UnifiedChalanListView oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.organization?.id != widget.organization?.id) {
//       _loadChalans();
//     }
//   }

//   void _loadChalans() {
//     if (widget.organization != null) {
//       context.read<UnifiedChalanBloc>().add(
//         LoadChalansEvent(widget.organization!.id),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.organization == null) {
//       return EmptyState(
//         icon: Icons.business,
//         title: context.t.noOrganizationSelected,
//         subtitle: context.t.selectOrCreateOrganization,
//         actionText: context.t.goToOrganizations,
//         onAction: () {
//           context.showSnackbar(context.t.goToOrganizationsTab);
//         },
//       );
//     }

//     return BlocListener<UnifiedChalanBloc, UnifiedChalanState>(
//       listener: (context, state) {
//         // Show error/success messages
//         if (state is UnifiedChalanError) {
//           context.showSnackbar(state.message, isError: true);
//         } else if (state is UnifiedChalanOperationSuccess) {
//           context.showSnackbar(state.message);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: context.colors.surface,
//         body: Column(
//           children: [
//             // Unified Search Bar
//             const UnifiedSearchBar(),

//             // Chalan List
//             Expanded(child: _buildChalanList(context)),
//           ],
//         ),
//         floatingActionButton: _buildFloatingActionButton(context),
//       ),
//     );
//   }

//   /// Build chalan list
//   Widget _buildChalanList(BuildContext context) {
//     return BlocBuilder<UnifiedChalanBloc, UnifiedChalanState>(
//       builder: (context, state) {
//         // Show loading state
//         if (state is UnifiedChalanInitial || state is UnifiedChalanLoading) {
//           return LoadingWidget(
//             message: context.t.loadingChalans,
//             showLogo: true,
//             height: 400.h,
//           );
//         }

//         // Show error state
//         if (state is UnifiedChalanError) {
//           return _buildErrorState(state.message);
//         }

//         // Show empty state for no chalans
//         if (state is UnifiedChalanEmpty) {
//           return EmptyState(
//             icon: Icons.receipt_long,
//             title: context.t.noChalansFound,
//             subtitle: context.t.addFirstChalan,
//             actionText: context.t.addChalan,
//             onAction: () => _navigateToAddChalan(context),
//           );
//         }

//         // Show filtered results
//         if (state is UnifiedChalanLoaded) {
//           final chalansToShow = state.filteredChalans;

//           if (chalansToShow.isEmpty && state.filter.hasActiveFilters) {
//             return EmptyState(
//               icon: Icons.filter_list_off,
//               title: context.t.noResultsFound,
//               subtitle: context.t.adjustFilters,
//               actionText: context.t.clearFilters,
//               onAction: () {
//                 context.read<UnifiedChalanBloc>().add(ClearAllFiltersEvent());
//               },
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () async {
//               context.read<UnifiedChalanBloc>().add(
//                 RefreshChalansEvent(widget.organization!.id),
//               );
//             },
//             color: context.colors.primary,
//             child: ListView.builder(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               itemCount: chalansToShow.length,
//               itemBuilder: (context, index) {
//                 final chalan = chalansToShow[index];
//                 return _buildChalanCard(context, chalan, index);
//               },
//             ),
//           );
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }

//   /// Build error state widget
//   Widget _buildErrorState(String message) {
//     return Center(
//       child: Container(
//         margin: EdgeInsets.all(24.w),
//         padding: EdgeInsets.all(24.w),
//         decoration: BoxDecoration(
//           color: context.colors.errorContainer,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: context.colors.error.withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline, size: 64.w, color: context.colors.error),
//             SizedBox(height: 16.h),
//             Text(
//               context.t.somethingWentWrong,
//               style: context.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: context.colors.onErrorContainer,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: context.textTheme.bodyMedium?.copyWith(
//                 color: context.colors.onErrorContainer,
//               ),
//             ),
//             SizedBox(height: 24.h),
//             ElevatedButton.icon(
//               onPressed: _loadChalans,
//               icon: const Icon(Icons.refresh),
//               label: Text(context.t.tryAgain),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: context.colors.error,
//                 foregroundColor: context.colors.onError,
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

//   /// Build individual chalan card
//   Widget _buildChalanCard(BuildContext context, Chalan chalan, int index) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 300 + (index * 50)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 30 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: Container(
//               margin: EdgeInsets.only(bottom: 12.h),
//               decoration: BoxDecoration(
//                 color: context.colors.surface,
//                 borderRadius: BorderRadius.circular(16.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: context.colors.shadow.withOpacity(0.1),
//                     blurRadius: 8.r,
//                     offset: Offset(0, 2.h),
//                   ),
//                 ],
//               ),
//               child: InkWell(
//                 onTap: () => _navigateToChalanDetail(context, chalan),
//                 borderRadius: BorderRadius.circular(16.r),
//                 child: Padding(
//                   padding: EdgeInsets.all(16.w),
//                   child: Row(
//                     children: [
//                       _buildChalanImage(context, chalan),
//                       SizedBox(width: 16.w),
//                       Expanded(child: _buildChalanInfo(context, chalan)),
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
//   Widget _buildChalanImage(BuildContext context, Chalan chalan) {
//     return Hero(
//       tag: 'chalan_image_${chalan.id}',
//       child: Container(
//         width: 60.w,
//         height: 60.h,
//         decoration: BoxDecoration(
//           color: context.colors.primary.withOpacity(0.1),
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
//                           color: context.colors.primary,
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
//                       color: context.colors.primary,
//                       size: 24.w,
//                     );
//                   },
//                 ),
//               )
//             : Icon(
//                 Icons.receipt_long,
//                 color: context.colors.primary,
//                 size: 24.w,
//               ),
//       ),
//     );
//   }

//   /// Build chalan info with creator details
//   Widget _buildChalanInfo(BuildContext context, Chalan chalan) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Chalan number and creator info
//         Row(
//           children: [
//             Text(
//               '#${chalan.chalanNumber}',
//               style: context.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: context.colors.onSurface,
//               ),
//             ),
//             const Spacer(),
//             // Creator badge
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//               decoration: BoxDecoration(
//                 color: _getCreatorColor(
//                   context,
//                   chalan.createdBy,
//                 ).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Text(
//                 _getCreatorRole(chalan.createdBy),
//                 style: context.textTheme.labelSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: _getCreatorColor(context, chalan.createdBy),
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
//             style: context.textTheme.bodyMedium?.copyWith(
//               color: context.colors.onSurface.withOpacity(0.7),
//             ),
//           ),

//         SizedBox(height: 8.h),

//         // Date
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//           decoration: BoxDecoration(
//             color: context.colors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Text(
//             _formatDate(chalan.dateTime),
//             style: context.textTheme.labelSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: context.colors.primary,
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
//               Icon(Icons.visibility, color: context.colors.primary, size: 20.w),
//               SizedBox(width: 12.w),
//               Text(
//                 context.t.view,
//                 style: context.textTheme.bodyMedium?.copyWith(
//                   color: context.colors.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'edit',
//           child: Row(
//             children: [
//               Icon(Icons.edit, color: Colors.orange, size: 20.w),
//               SizedBox(width: 12.w),
//               Text(
//                 context.t.edit,
//                 style: context.textTheme.bodyMedium?.copyWith(
//                   color: context.colors.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'delete',
//           child: Row(
//             children: [
//               Icon(Icons.delete, color: context.colors.error, size: 20.w),
//               SizedBox(width: 12.w),
//               Text(
//                 context.t.delete,
//                 style: context.textTheme.bodyMedium?.copyWith(
//                   color: context.colors.error,
//                 ),
//               ),
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
//             _showDeleteConfirmation(context, chalan);
//             break;
//         }
//       },
//     );
//   }

//   /// Build floating action button
//   Widget _buildFloatingActionButton(BuildContext context) {
//     return BlocBuilder<UnifiedChalanBloc, UnifiedChalanState>(
//       builder: (context, state) {
//         // Hide FAB during loading
//         if (state is UnifiedChalanLoading) {
//           return const SizedBox.shrink();
//         }

//         return FloatingActionButton.extended(
//           onPressed: () => _navigateToAddChalan(context),
//           icon: const Icon(Icons.add),
//           label: Text(
//             context.t.addChalan,
//             style: context.textTheme.labelLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           backgroundColor: context.colors.primary,
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
//     if (createdBy == null) return context.t.unknown;

//     // Check if current user
//     final currentUserId = supabase.auth.currentUser?.id;
//     if (createdBy == currentUserId) return context.t.me;

//     // Check organization role (you might want to fetch this from database)
//     // For now, return generic role
//     return context.t.member;
//   }

//   /// Get creator role color
//   Color _getCreatorColor(BuildContext context, String? createdBy) {
//     if (createdBy == null) return context.colors.outline;

//     final currentUserId = supabase.auth.currentUser?.id;
//     if (createdBy == currentUserId) return Colors.green;

//     return context.colors.primary;
//   }

//   /// Navigation methods
//   void _navigateToAddChalan(BuildContext context) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddChalanPage(organization: widget.organization!),
//       ),
//     );

//     if (result == true) {
//       context.read<UnifiedChalanBloc>().add(
//         RefreshChalansEvent(widget.organization!.id),
//       );
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
//       context.read<UnifiedChalanBloc>().add(
//         RefreshChalansEvent(widget.organization!.id),
//       );
//     }
//   }

//   void _navigateToChalanDetail(BuildContext context, Chalan chalan) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => ChalanDetailPage(chalan: chalan)),
//     );
//   }

//   /// Show delete confirmation dialog
//   Future<void> _showDeleteConfirmation(
//     BuildContext context,
//     Chalan chalan,
//   ) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(context.t.delete),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               context.t.deleteChalanConfirmation,
//               style: context.textTheme.bodyMedium?.copyWith(
//                 color: context.colors.onSurface,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: context.colors.surfaceContainerHighest.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.receipt_long,
//                     color: context.colors.primary,
//                     size: 20.w,
//                   ),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     child: Text(
//                       '#${chalan.chalanNumber}',
//                       style: context.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: context.colors.onSurface,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               context.t.actionCannotBeUndone,
//               style: context.textTheme.bodySmall?.copyWith(
//                 color: context.colors.error,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(context.t.cancel),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: context.colors.error,
//               foregroundColor: context.colors.onError,
//             ),
//             child: Text(context.t.delete),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       context.read<UnifiedChalanBloc>().add(DeleteChalanEvent(chalan));
//     }
//   }

//   /// Format date helper
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
