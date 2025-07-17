import 'package:chalan_book_app/bloc/chalan/chalan_bloc.dart';
import 'package:chalan_book_app/bloc/chalan/chalan_event.dart';
import 'package:chalan_book_app/bloc/chalan/chalan_state.dart';
import 'package:chalan_book_app/bloc/organization/organization_bloc.dart';
import 'package:chalan_book_app/features/chalan/views/add_chalan_page.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/shared/widgets/loding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/filter/filter_bloc.dart';
import '../../../bloc/filter/filter_event.dart';
import '../../../bloc/filter/filter_state.dart';
import '../../../core/models/chalan.dart';
import '../../../core/models/organization.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../filter/filter_model.dart';
import 'chalan_detail_page.dart';

class ChalanListPageWithFilters extends StatelessWidget {
  final Organization? organization;

  const ChalanListPageWithFilters({super.key, required this.organization});

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
          create: (context) => ChalanFilterBloc(),
        ),
      ],
      child: ChalanListViewWithFilters(organization: organization),
    );
  }
}

class ChalanListViewWithFilters extends StatefulWidget {
  final Organization? organization;

  const ChalanListViewWithFilters({super.key, required this.organization});

  @override
  State<ChalanListViewWithFilters> createState() => _ChalanListViewWithFiltersState();
}

class _ChalanListViewWithFiltersState extends State<ChalanListViewWithFilters> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChalans();
  }

  @override
  void didUpdateWidget(ChalanListViewWithFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organization?.id != widget.organization?.id) {
      _loadChalans();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Go to the Organizations tab')),
          );
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

          context.read<ChalanFilterBloc>().updateOriginalChalans(chalans);
        }

        // Show error/success messages
        if (state is ChalanErrorState) {
          _showSnackBar(state.message, isError: true);
        } else if (state is ChalanOperationSuccessState) {
          _showSnackBar(state.message);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Header with organization info and search
            _buildHeaderWithSearch(context),

            // Filter chips
            _buildFilterChips(context),

            // Chalan list
            Expanded(
              child: _buildChalanList(context),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  /// Build header with search functionality
  Widget _buildHeaderWithSearch(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Organization info
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.receipt_long, color: Colors.blue, size: 24.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.organization?.name ?? 'Chalans',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    BlocBuilder<ChalanFilterBloc, ChalanFilterState>(
                      builder: (context, state) {
                        final count = state.filteredChalans.length;
                        final total = state.originalChalans.length;

                        return Text(
                          count == total
                              ? '$count ${count == 1 ? 'chalan' : 'chalans'}'
                              : '$count of $total chalans',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chalan number or date (e.g. 1002, 2025-07-15)',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<ChalanFilterBloc>().add(
                      UpdateSearchQueryEvent(''),
                    );
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: (query) {
                context.read<ChalanFilterBloc>().add(
                  UpdateSearchQueryEvent(query),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<ChalanFilterBloc, ChalanFilterState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Date filter chips
                _buildFilterChip(
                  '📆 This Year',
                  state.filter.filterType == FilterType.thisYear,
                      () => context.read<ChalanFilterBloc>().add(
                    ChangeFilterTypeEvent(FilterType.thisYear),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  '🔄 All Years',
                  state.filter.filterType == FilterType.allYears,
                      () => context.read<ChalanFilterBloc>().add(
                    ChangeFilterTypeEvent(FilterType.allYears),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  '👤 Created By Me',
                  state.filter.filterType == FilterType.createdByMe,
                      () => context.read<ChalanFilterBloc>().add(
                    ChangeFilterTypeEvent(FilterType.createdByMe),
                  ),
                ),
                SizedBox(width: 8.w),

                // Number range filters
                _buildFilterChip(
                  '🔢 Below 20',
                  state.filter.chalanNumberRange == ChalanNumberRange.below20,
                      () => context.read<ChalanFilterBloc>().add(
                    SetChalanNumberRangeEvent(ChalanNumberRange.below20),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  '🔢 20-80',
                  state.filter.chalanNumberRange == ChalanNumberRange.between20And80,
                      () => context.read<ChalanFilterBloc>().add(
                    SetChalanNumberRangeEvent(ChalanNumberRange.between20And80),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  '🔢 Above 80',
                  state.filter.chalanNumberRange == ChalanNumberRange.above80,
                      () => context.read<ChalanFilterBloc>().add(
                    SetChalanNumberRangeEvent(ChalanNumberRange.above80),
                  ),
                ),

                // Clear filters button
                if (state.filter.isActive) ...[
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      context.read<ChalanFilterBloc>().add(ClearAllFiltersEvent());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear_all, size: 16.w, color: Colors.red),
                          SizedBox(width: 4.w),
                          Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Build chalan list with filtering
  Widget _buildChalanList(BuildContext context) {
    return BlocBuilder<ChalanFilterBloc, ChalanFilterState>(
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

            if (chalansToShow.isEmpty && filterState.filter.isActive) {
              return EmptyState(
                icon: Icons.filter_list_off,
                title: 'No Results Found',
                subtitle: 'Try adjusting your filters or search terms',
                actionText: 'Clear Filters',
                onAction: () {
                  _searchController.clear();
                  context.read<ChalanFilterBloc>().add(ClearAllFiltersEvent());
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChalanBloc>().add(
                  RefreshChalansEvent(widget.organization!),
                );
              },
              color: Colors.blue,
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
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadChalans,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
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

  /// Build individual chalan card with creator info
  Widget _buildChalanCard(BuildContext context, Chalan chalan, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              margin: EdgeInsets.only(bottom: 12.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: InkWell(
                onTap: () => _navigateToChalanDetail(context, chalan),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      _buildChalanImage(chalan),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildChalanInfo(chalan)),
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
  Widget _buildChalanImage(Chalan chalan) {
    return Hero(
      tag: 'chalan_image_${chalan.id}',
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
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
                color: Colors.blue,
                size: 24.w,
              );
            },
          ),
        )
            : Icon(Icons.receipt_long, color: Colors.blue, size: 24.w),
      ),
    );
  }

  /// Build chalan info with creator details
  Widget _buildChalanInfo(Chalan chalan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chalan number and creator info
        Row(
          children: [
            Text(
              chalan.chalanNumber,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            // Creator badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _getCreatorColor(chalan.createdBy).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _getCreatorRole(chalan.createdBy),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _getCreatorColor(chalan.createdBy),
                  fontWeight: FontWeight.w600,
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),

        SizedBox(height: 8.h),

        // Date
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _formatDate(chalan.dateTime),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
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
              Icon(Icons.visibility, color: Colors.blue, size: 20.w),
              SizedBox(width: 12.w),
              const Text('View'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange, size: 20.w),
              SizedBox(width: 12.w),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20.w),
              SizedBox(width: 12.w),
              const Text('Delete', style: TextStyle(color: Colors.red)),
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
            _showDeleteConfirmation(chalan);
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
          label: const Text('Add Chalan'),
          backgroundColor: Colors.blue,
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
  Color _getCreatorColor(String? createdBy) {
    if (createdBy == null) return Colors.grey;

    final currentUserId = supabase.auth.currentUser?.id;
    if (createdBy == currentUserId) return Colors.green;

    return Colors.blue;
  }

  /// Navigation methods
  void _navigateToAddChalan(BuildContext context) async {
    final chalans = context.read<ChalanFilterBloc>().state.originalChalans;
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
  Future<void> _showDeleteConfirmation(Chalan chalan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.w),
            SizedBox(width: 12.w),
            const Text('Delete Chalan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this chalan?'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.blue, size: 20.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      chalan.chalanNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red[600], fontSize: 12.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ChalanBloc>().add(DeleteChalanEvent(chalan));
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// Format date helper
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
