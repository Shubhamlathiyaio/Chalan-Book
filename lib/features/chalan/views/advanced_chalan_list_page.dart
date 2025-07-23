// import 'package:chalan_book_app/features/organization/views/chalan_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../core/extensions/context_extension.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../../../core/models/chalan.dart';
// import '../../../core/models/organization.dart';
// import '../../../main.dart';
// import '../../chalan/bloc/chalan_bloc.dart';
// import '../../chalan/views/add_chalan_page.dart';
// import '../../filter/advanced_filter_bloc.dart';
// import '../../filter/advanced_filter_state.dart';
// import '../../organization/bloc/organization_bloc.dart';
// import '../../shared/widgets/empty_state.dart';
// import '../../shared/widgets/loading.dart';
// import '../widgets/advanced_search_bar.dart';

// /// Advanced Chalan List Page with comprehensive filtering
// class AdvancedChalanListPage extends StatelessWidget {
//   final Organization? organization;

//   const AdvancedChalanListPage({super.key, required this.organization});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) =>
//               ChalanBloc(organizationBloc: context.read<OrganizationBloc>()),
//         ),
//         BlocProvider(create: (context) => AdvancedChalanFilterBloc()),
//       ],
//       child: AdvancedChalanListView(organization: organization),
//     );
//   }
// }

// /// Main view with advanced filtering
// class AdvancedChalanListView extends StatefulWidget {
//   final Organization? organization;

//   const AdvancedChalanListView({super.key, required this.organization});

//   @override
//   State<AdvancedChalanListView> createState() => _AdvancedChalanListViewState();
// }

// class _AdvancedChalanListViewState extends State<AdvancedChalanListView> {
//   @override
//   void initState() {
//     super.initState();
//     _loadChalans();
//   }

//   @override
//   void didUpdateWidget(AdvancedChalanListView oldWidget) {
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
//     final l10n = AppLocalizations.of(context)!;

//     if (widget.organization == null) {
//       return EmptyState(
//         icon: Icons.business,
//         title: l10n.translate('no_organization_selected'),
//         subtitle: l10n.translate('select_or_create_organization'),
//         actionText: l10n.translate('go_to_organizations'),
//         onAction: () {
//           context.showSnackbar(l10n.translate('go_to_organizations_tab'));
//         },
//       );
//     }

//     return BlocListener<ChalanBloc, ChalanState>(
//       listener: (context, state) {
//         // Update filter bloc when chalans are loaded
//         if (state is ChalanLoaded || state is ChalanOperationSuccess) {
//           final chalans = state is ChalanLoaded
//               ? state.chalans
//               : (state as ChalanOperationSuccess).chalans;

//           context.read<AdvancedChalanFilterBloc>().updateOriginalChalans(
//             chalans,
//           );
//         }

//         // Show error/success messages
//         if (state is ChalanError) {
//           context.showSnackbar(state.message, isError: true);
//         } else if (state is ChalanOperationSuccess) {
//           context.showSnackbar(state.message);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: context.colors.surface,
//         body: Column(
//           children: [
//             // Advanced Search Bar
//             const AdvancedSearchBar(),

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
//     return BlocBuilder<AdvancedChalanFilterBloc, AdvancedChalanFilterState>(
//       builder: (context, filterState) {
//         return BlocBuilder<ChalanBloc, ChalanState>(
//           builder: (context, chalanState) {
//             // Show loading state
//             if (chalanState is ChalanInitial || chalanState is ChalanLoading) {
//               return LoadingWidget(
//                 message: AppLocalizations.of(
//                   context,
//                 )!.translate('loading_chalans'),
//                 showLogo: true,
//                 height: 400.h,
//               );
//             }

//             // Show error state
//             if (chalanState is ChalanError) {
//               return _buildErrorState(chalanState.message);
//             }

//             // Show empty state for no chalans
//             if (chalanState is ChalanEmpty) {
//               return EmptyState(
//                 icon: Icons.receipt_long,
//                 title: AppLocalizations.of(
//                   context,
//                 )!.translate('no_chalans_found'),
//                 subtitle: AppLocalizations.of(
//                   context,
//                 )!.translate('add_first_chalan'),
//                 actionText: AppLocalizations.of(
//                   context,
//                 )!.translate('add_chalan'),
//                 onAction: () => _navigateToAddChalan(context),
//               );
//             }

//             // Show filtered results
//             final chalansToShow = filterState.filteredChalans;

//             if (chalansToShow.isEmpty && filterState.filter.hasActiveFilters) {
//               return EmptyState(
//                 icon: Icons.filter_list_off,
//                 title: AppLocalizations.of(
//                   context,
//                 )!.translate('no_results_found'),
//                 subtitle: AppLocalizations.of(
//                   context,
//                 )!.translate('adjust_filters'),
//                 actionText: AppLocalizations.of(
//                   context,
//                 )!.translate('clear_filters'),
//                 onAction: () {
//                   // context.read<AdvancedChalanFilterBloc>().add(
//                   //   ClearAllFilters(),
//                   // );
//                 },
//               );
//             }

//             return RefreshIndicator(
//               onRefresh: () async {
//                 context.read<ChalanBloc>().add(
//                   RefreshChalansEvent(widget.organization!),
//                 );
//               },
//               color: context.colors.primary,
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 itemCount: chalansToShow.length,
//                 itemBuilder: (context, index) {
//                   final chalan = chalansToShow[index];
//                   return _buildChalanCard(context, chalan, index);
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Build error state widget
//   Widget _buildErrorState(String message) {
//     final l10n = AppLocalizations.of(context)!;

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
//               l10n.translate('something_went_wrong'),
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
//               label: Text(l10n.translate('try_again')),
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
//     final l10n = AppLocalizations.of(context)!;

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
//                 l10n.translate('view'),
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
//                 l10n.translate('edit'),
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
//                 l10n.translate('delete'),
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
//     final l10n = AppLocalizations.of(context)!;

//     return BlocBuilder<ChalanBloc, ChalanState>(
//       builder: (context, state) {
//         // Hide FAB during loading
//         if (state is ChalanLoading) {
//           return const SizedBox.shrink();
//         }

//         return FloatingActionButton.extended(
//           onPressed: () => _navigateToAddChalan(context),
//           icon: const Icon(Icons.add),
//           label: Text(
//             l10n.translate('add_chalan'),
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
//     final l10n = AppLocalizations.of(context)!;

//     if (createdBy == null) return l10n.translate('unknown');

//     // Check if current user
//     final currentUserId = supabase.auth.currentUser?.id;
//     if (createdBy == currentUserId) return l10n.translate('me');

//     // Check organization role (you might want to fetch this from database)
//     // For now, return generic role
//     return l10n.translate('member');
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
//     final chalans = context
//         .read<AdvancedChalanFilterBloc>()
//         .state
//         .originalChalans;
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
//           // nextChalanNumber: max + 1,
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
//         builder: (_) => AddChalanPage(
//           organization: widget.organization!,

//           //  chalan: chalan
//         ),
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
//   Future<void> _showDeleteConfirmation(
//     BuildContext context,
//     Chalan chalan,
//   ) async {
//     final l10n = AppLocalizations.of(context)!;

//     final confirmed = await showDialog(
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             l10n.translate('delete_chalan_confirmation'),
//             style: context.textTheme.bodyMedium?.copyWith(
//               color: context.colors.onSurface,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: context.colors.surfaceContainerHighest.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.receipt_long,
//                   color: context.colors.primary,
//                   size: 20.w,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     '#${chalan.chalanNumber}',
//                     style: context.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: context.colors.onSurface,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             l10n.translate('action_cannot_be_undone'),
//             style: context.textTheme.bodySmall?.copyWith(
//               color: context.colors.error,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   /// Format date helper
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

