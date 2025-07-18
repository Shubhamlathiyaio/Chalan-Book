import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_bloc.dart';
import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_event.dart';
import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_state.dart';
import 'package:chalan_book_app/core/configs/app_typography.dart';
import 'package:chalan_book_app/features/chalan/views/add_chalan_page.dart';
import 'package:chalan_book_app/features/organization/views/chalan_detail_page.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/shared/widgets/advanced_search_bar.dart';
import 'package:chalan_book_app/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/chalan/chalan_bloc.dart';
import '../../../bloc/chalan/chalan_event.dart';
import '../../../bloc/chalan/chalan_state.dart';
import '../../../bloc/organization/organization_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chalan.dart';
import '../../../core/models/organization.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loding.dart';

/// Advanced Chalan List Page with comprehensive filtering
class AdvancedChalanListPage extends StatelessWidget {
  final Organization? organization;

  const AdvancedChalanListPage({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ChalanBloc(
            organizationBloc: context.read<OrganizationBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => AdvancedChalanFilterBloc(),
        ),
      ],
      child: AdvancedChalanListView(organization: organization),
    );
  }
}

/// Main view with advanced filtering
class AdvancedChalanListView extends StatefulWidget {
  final Organization? organization;

  const AdvancedChalanListView({super.key, required this.organization});

  @override
  State<AdvancedChalanListView> createState() => _AdvancedChalanListViewState();
}

class _AdvancedChalanListViewState extends State<AdvancedChalanListView> {
  @override
  void initState() {
    super.initState();
    _loadChalans();
  }

  @override
  void didUpdateWidget(AdvancedChalanListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organization?.id != widget.organization?.id) {
      _loadChalans();
    }
  }

  void _loadChalans() {
    if (widget.organization != null) {
      context.read<ChalanBloc>().add(LoadChalansEvent(widget.organization!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.organization == null) {
      return EmptyState(
        icon: Icons.business,
        title: 'No Organization Selected',
        subtitle: 'Please select or create an organization first',
        actionText: 'Go to Organizations',
        onAction: () {
          context.showSnackbar('Go to the Organizations tab');
        },
      );
    }

    return BlocListener<ChalanBloc, ChalanState>(
      listener: (context, state) {
        // Update filter bloc when chalans are loaded
        if (state is ChalanLoadedState || state is ChalanOperationSuccessState) {
          final chalans = state is ChalanLoadedState
              ? state.chalans
              : (state as ChalanOperationSuccessState).chalans;

          context.read<AdvancedChalanFilterBloc>().updateOriginalChalans(chalans);
        }

        // Show error/success messages
        if (state is ChalanErrorState) {
          context.showSnackbar(state.message);
        } else if (state is ChalanOperationSuccessState) {
          context.showSnackbar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            // Organization Header
            _buildOrganizationHeader(context),

            // Advanced Search Bar
            const AdvancedSearchBar(),

            // Results Summary
            _buildResultsSummary(context),

            // Chalan List
            Expanded(
              child: _buildChalanList(context),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  /// Build organization header
  Widget _buildOrganizationHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.receipt_long,
              color: context.colors.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.organization?.name ?? 'Chalans',
                  style: poppins.w700.fs18.textColor(context.colors.onSurface),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Manage your chalans efficiently',
                  style: poppins.w400.fs12.textColor(
                    context.colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build results summary
  Widget _buildResultsSummary(BuildContext context) {
    return BlocBuilder<AdvancedChalanFilterBloc, AdvancedChalanFilterState>(
      builder: (context, state) {
        final filteredCount = state.filteredChalans.length;
        final totalCount = state.originalChalans.length;
        final hasFilters = state.filter.hasActiveFilters;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                hasFilters
                    ? 'Showing $filteredCount of $totalCount chalans'
                    : '$totalCount ${totalCount == 1 ? 'chalan' : 'chalans'}',
                style: poppins.w500.fs12.textColor(
                  context.colors.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              if (hasFilters)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.xff002568.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${state.filter.activeFilterCount} filters active',
                    style: poppins.w500.fs10.textColor(AppColors.xff002568),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build chalan list
  Widget _buildChalanList(BuildContext context) {
    return BlocBuilder<AdvancedChalanFilterBloc, AdvancedChalanFilterState>(
      builder: (context, filterState) {
        return BlocBuilder<ChalanBloc, ChalanState>(
          builder: (context, chalanState) {
            // Show loading state
            if (chalanState is ChalanInitialState || chalanState is ChalanLoadingState) {
              return LoadingWidget(
                message: 'Loading your chalans...',
                showLogo: true,
                height: 400.h,
              );
            }

            // Show error state
            if (chalanState is ChalanErrorState) {
              return _buildErrorState(chalanState.message);
            }

            // Show empty state for no chalans
            if (chalanState is ChalanEmptyState) {
              return EmptyState(
                icon: Icons.receipt_long,
                title: 'No Chalans Found',
                subtitle: 'Add your first chalan to get started',
                actionText: 'Add Chalan',
                onAction: () => _navigateToAddChalan(context),
              );
            }

            // Show filtered results
            final chalansToShow = filterState.filteredChalans;

            if (chalansToShow.isEmpty && filterState.filter.hasActiveFilters) {
              return EmptyState(
                icon: Icons.filter_list_off,
                title: 'No Results Found',
                subtitle: 'Try adjusting your filters or search terms',
                actionText: 'Clear Filters',
                onAction: () {
                  context.read<AdvancedChalanFilterBloc>().add(ClearAllFiltersEvent());
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChalanBloc>().add(
                  RefreshChalansEvent(widget.organization!),
                );
              },
              color: context.colors.primary,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: chalansToShow.length,
                itemBuilder: (context, index) {
                  final chalan = chalansToShow[index];
                  return _buildChalanCard(context, chalan, index);
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Build error state widget
  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.colors.errorContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.error.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: context.colors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: poppins.w700.fs18.textColor(context.colors.onErrorContainer),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: poppins.w400.fs14.textColor(context.colors.onErrorContainer),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadChalans,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.error,
                foregroundColor: context.colors.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual chalan card
  Widget _buildChalanCard(BuildContext context, Chalan chalan, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withOpacity(0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _navigateToChalanDetail(context, chalan),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      _buildChalanImage(context, chalan),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildChalanInfo(context, chalan)),
                      _buildChalanMenu(context, chalan),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build chalan image
  Widget _buildChalanImage(BuildContext context, Chalan chalan) {
    return Hero(
      tag: 'chalan_image_${chalan.id}',
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: chalan.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  chalan.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.primary,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.receipt_long,
                      color: context.colors.primary,
                      size: 24.w,
                    );
                  },
                ),
              )
            : Icon(
                Icons.receipt_long,
                color: context.colors.primary,
                size: 24.w,
              ),
      ),
    );
  }

  /// Build chalan info with creator details
  Widget _buildChalanInfo(BuildContext context, Chalan chalan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chalan number and creator info
        Row(
          children: [
            Text(
              '#${chalan.chalanNumber}',
              style: poppins.w700.fs16.textColor(context.colors.onSurface),
            ),
            const Spacer(),
            // Creator badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _getCreatorColor(context, chalan.createdBy).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _getCreatorRole(chalan.createdBy),
                style: poppins.w600.fs10.textColor(
                  _getCreatorColor(context, chalan.createdBy),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Description
        if (chalan.description != null && chalan.description!.isNotEmpty)
          Text(
            chalan.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: poppins.w400.fs14.textColor(
              context.colors.onSurface.withOpacity(0.7),
            ),
          ),

        SizedBox(height: 8.h),

        // Date
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _formatDate(chalan.dateTime),
            style: poppins.w500.fs12.textColor(context.colors.primary),
          ),
        ),
      ],
    );
  }

  /// Build chalan menu
  Widget _buildChalanMenu(BuildContext context, Chalan chalan) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.visibility,
                color: context.colors.primary,
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'View',
                style: poppins.w500.fs14.textColor(context.colors.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                color: Colors.orange,
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Edit',
                style: poppins.w500.fs14.textColor(context.colors.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: context.colors.error,
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Delete',
                style: poppins.w500.fs14.textColor(context.colors.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'view':
            _navigateToChalanDetail(context, chalan);
            break;
          case 'edit':
            _navigateToEditChalan(context, chalan);
            break;
          case 'delete':
            _showDeleteConfirmation(context, chalan);
            break;
        }
      },
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<ChalanBloc, ChalanState>(
      builder: (context, state) {
        // Hide FAB during loading
        if (state is ChalanLoadingState) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => _navigateToAddChalan(context),
          icon: const Icon(Icons.add),
          label: Text(
            'Add Chalan',
            style: poppins.w600.fs14.textColor(Colors.white),
          ),
          backgroundColor: AppColors.xff002568,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  /// Get creator role display text
  String _getCreatorRole(String? createdBy) {
    if (createdBy == null) return 'Unknown';

    // Check if current user
    final currentUserId = supabase.auth.currentUser?.id;
    if (createdBy == currentUserId) return 'Me';

    // Check organization role (you might want to fetch this from database)
    // For now, return generic role
    return 'Member';
  }

  /// Get creator role color
  Color _getCreatorColor(BuildContext context, String? createdBy) {
    if (createdBy == null) return context.colors.outline;

    final currentUserId = supabase.auth.currentUser?.id;
    if (createdBy == currentUserId) return Colors.green;

    return context.colors.primary;
  }

  /// Navigation methods
  void _navigateToAddChalan(BuildContext context) async {
    final chalans = context.read<AdvancedChalanFilterBloc>().state.originalChalans;
    final max = chalans.isNotEmpty
        ? chalans.map((c) => int.tryParse(c.chalanNumber) ?? 0).reduce((a, b) => a > b ? a : b)
        : 0;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChalanPage(
          organization: widget.organization!,
          nextChalanNumber: max + 1,
        ),
      ),
    );

    if (result == true) {
      context.read<ChalanBloc>().add(RefreshChalansEvent(widget.organization!));
    }
  }

  void _navigateToEditChalan(BuildContext context, Chalan chalan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChalanPage(
          organization: widget.organization!,
          chalan: chalan,
        ),
      ),
    );

    if (result == true) {
      context.read<ChalanBloc>().add(RefreshChalansEvent(widget.organization!));
    }
  }

  void _navigateToChalanDetail(BuildContext context, Chalan chalan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChalanDetailPage(chalan: chalan),
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(BuildContext context, Chalan chalan) async {
    final confirmed = await context.popup(
      title: 'Delete Chalan',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this chalan?',
            style: poppins.w400.fs14.textColor(context.colors.onSurface),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: context.colors.primary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '#${chalan.chalanNumber}',
                    style: poppins.w600.fs14.textColor(context.colors.onSurface),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This action cannot be undone.',
            style: poppins.w400.fs12.textColor(context.colors.error),
          ),
        ],
      ),
      confirmText: 'Delete',
      onConfirm: () {
        context.read<ChalanBloc>().add(DeleteChalanEvent(chalan));
      },
    );
  }

  /// Format date helper
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
