import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/features/chalan/views/add_chalan_page.dart';
import 'package:chalan_book_app/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/chalan.dart';
import '../../../core/models/organization.dart';
import '../../../main.dart';
import '../../../shared/widgets/empty_state.dart';
import 'chalan_detail_page.dart';

class ChalanListPage extends StatefulWidget {
  final Organization? organization;

  const ChalanListPage({super.key, required this.organization});

  @override
  State<ChalanListPage> createState() => _ChalanListPageState();
}

class _ChalanListPageState extends State<ChalanListPage> {
  List<Chalan> _chalans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChalans();
  }

  @override
  void didUpdateWidget(ChalanListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organization?.id != widget.organization?.id) {
      _loadChalans();
    }
  }

  void _loadChalans() async {
    if (widget.organization == null) {
      setState(() {
        _chalans = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from(chalansTable)
          .select()
          .eq('organization_id', widget.organization!.id)
          .order('date_time', ascending: false);

      final chalans = response.map((item) => Chalan.fromJson(item)).toList();

      setState(() {
        _chalans = chalans;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showSnackBar('Error loading chalans: $error', isError: true);
      }
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chalans.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: AppStrings.noChalans,
        subtitle: 'Add your first chalan to get started',
        actionText: AppStrings.addChalan,
        onAction: () => _navigateToAddChalan(),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Chalans (${_chalans.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToAddChalan,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _chalans.length,
            itemBuilder: (context, index) {
              final chalan = _chalans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: chalan.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              chalan.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.receipt_long,
                                  color: Colors.blue,
                                );
                              },
                            ),
                          )
                        : const Icon(Icons.receipt_long, color: Colors.blue),
                  ),
                  title: Text(
                    chalan.chalanNumber,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chalan.description ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(chalan.dateTime),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToAddChalan(chalan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.popup(
                            title: "Are you sure Delete Chalan",
                            content: Text("This action will permanently delete this chalan. Are you sure you want to continue?"),
                            cancelText: "Cancel",onConfirm: () {},
                          );
                        },
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () => _navigateToChalanDetail(chalan),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToAddChalan([Chalan? chalan]) async {
    final bool result;
    if (chalan == null) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddChalanPage(organization: widget.organization!),
        ),
      );
    } else {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AddChalanPage(organization: widget.organization!, chalan: chalan),
        ),
      );
    }

    if (result == true) {
      _loadChalans();
    }
  }

  void _navigateToChalanDetail(Chalan chalan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChalanDetailPage(chalan: chalan)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
