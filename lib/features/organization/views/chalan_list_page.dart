import 'package:chalan_book_app/bloc/chalan/chalan_bloc.dart';
import 'package:chalan_book_app/bloc/chalan/chalan_event.dart';
import 'package:chalan_book_app/bloc/chalan/chalan_state.dart';
import 'package:chalan_book_app/bloc/organization/organization_bloc.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/features/chalan/views/add_chalan_page.dart';
import 'package:chalan_book_app/shared/widgets/loding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/chalan.dart';
import '../../../core/models/organization.dart';
import '../../../shared/widgets/empty_state.dart';
import 'chalan_detail_page.dart';

class ChalanListPage extends StatelessWidget {
  final Organization? organization;

  const ChalanListPage({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChalanBloc(organizationBloc: context.read<OrganizationBloc>()),
      child: ChalanListView(organization: organization),
    );
  }
}

class ChalanListView extends StatefulWidget {
  final Organization? organization;

  const ChalanListView({super.key, required this.organization});

  @override
  State<ChalanListView> createState() => _ChalanListViewState();
}

class _ChalanListViewState extends State<ChalanListView> {
  @override
  void initState() {
    super.initState();
    _loadChalans();
  }

  @override
  void didUpdateWidget(ChalanListView oldWidget) {
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
            Text('Are you sure you want to delete this chalan?'),
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
                      style: TextStyle(fontWeight: FontWeight.w600),
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
            child: Text('Cancel'),
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
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print("^^^^^^^^^^^^^^^^^^^^^");
      print("Deleting chalan: ${chalan.chalanNumber}");
      context.read<ChalanBloc>().add(DeleteChalanEvent(chalan));
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
          // This will be handled by the parent widget's bottom navigation
        },
      );
    }

    return BlocConsumer<ChalanBloc, ChalanState>(
      listener: (context, state) {
        if (state is ChalanErrorState) {
          _showSnackBar(state.message, isError: true);
        } else if (state is ChalanOperationSuccessState) {
          _showSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, state),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(context, state),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ChalanState state) {
    int chalanCount = 0;
    bool isLoading = state is ChalanLoadingState;

    if (state is ChalanLoadedState) {
      chalanCount = state.chalans.length;
    } else if (state is ChalanOperationSuccessState) {
      chalanCount = state.chalans.length;
    }

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
      child: Row(
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
                if (isLoading)
                  Text(
                    'Loading chalans...',
                    style: TextStyle(fontSize: 14.sp, color: Colors.blue[600]),
                  )
                else if (chalanCount > 0)
                  Text(
                    '$chalanCount ${chalanCount == 1 ? 'chalan' : 'chalans'}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  )
                else
                  Text(
                    'No chalans yet',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChalanState state) {
    // ✅ Better loading state
    if (state is ChalanInitialState || state is ChalanLoadingState) {
      return LoadingWidget(
        message: 'Loading your chalans...',
        showLogo: true,
        height: 400.h,
      );
    }

    if (state is ChalanEmptyState) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: AppStrings.noChalans,
        subtitle: 'Add your first chalan to get started',
        actionText: AppStrings.addChalan,
        onAction: () => _navigateToAddChalan(context),
      );
    }

    if (state is ChalanErrorState) {
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
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _loadChalans,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
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

    List<Chalan> chalans = [];
    if (state is ChalanLoadedState) {
      chalans = state.chalans;
    } else if (state is ChalanOperationSuccessState) {
      chalans = state.chalans;
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
        itemCount: chalans.length,
        itemBuilder: (context, index) {
          final chalan = chalans[index];
          return _buildChalanCard(context, chalan, index);
        },
      ),
    );
  }

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

  Widget _buildChalanInfo(Chalan chalan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chalan.chalanNumber,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          chalan.description ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 8.h),
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

  Widget _buildFloatingActionButton(BuildContext context, ChalanState state) {
    // Hide FAB during loading
    if (state is ChalanLoadingState) {
      return SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddChalan(context),
      icon: Icon(Icons.add),
      label: Text('Add Chalan'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }

  void _navigateToAddChalan(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChalanPage(organization: widget.organization!),
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
        builder: (_) =>
            AddChalanPage(organization: widget.organization!, chalan: chalan),
      ),
    );
    if (result == true) {
      context.read<ChalanBloc>().add(RefreshChalansEvent(widget.organization!));
    }
  }

  void _navigateToChalanDetail(BuildContext context, Chalan chalan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChalanDetailPage(chalan: chalan)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
