import 'package:chalan_book_app/core/configs/app_typography.dart';
import 'package:chalan_book_app/core/constants/app_colors.dart';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_bloc.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_invite/organization_invite_bloc.dart';
import 'package:chalan_book_app/features/organization/views/organization_detail_page.dart';
import 'package:chalan_book_app/features/shared/widgets/empty_state.dart';
import 'package:chalan_book_app/features/shared/widgets/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/organization.dart';
import '../../../main.dart';
import 'create_organization_page.dart';

class OrganizationListPage extends StatefulWidget {
  final VoidCallback onOrganizationCreated;

  const OrganizationListPage({super.key, required this.onOrganizationCreated});

  @override
  State<OrganizationListPage> createState() => _OrganizationListPageState();
}

class _OrganizationListPageState extends State<OrganizationListPage> {
  bool _isLoading = true;
  List<Organization> _organizations = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from(AppKeys.organizationUsersTable)
          .select('organization_id, organizations:organization_id(*)')
          .eq('user_id', user.id);

      final orgs = response
          .where((row) => row['organizations'] != null)
          .map<Organization>(
            (row) => Organization.fromJson(row['organizations']),
          )
          .toList();

      setState(() {
        _organizations = orgs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showSnackbar('Error loading organizations: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_organizations.isEmpty) {
      return EmptyState(
        icon: Icons.business,
        title: AppStrings.noOrganizations,
        subtitle: 'Create your first organization to get started',
        actionText: AppStrings.createOrganization,
        onAction: _navigateToCreateOrganization,
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
                  'Organizations (${_organizations.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToCreateOrganization,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _organizations.length,
            itemBuilder: (context, index) {
              final org = _organizations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Stack(
                  children: [
                    ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrganizationDetailPage(organization: org),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          org.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        org.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (org.description != null) Text(org.description??""),
                          Text(
                            'Created ${formatDate(org.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          supabase.auth.currentUser?.id == org.ownerId
                              ? "Owned"
                              : "Joined",
                          style: poppins.w400.fs10.textColor(
                            supabase.auth.currentUser?.id == org.ownerId
                                ? AppColors.xff725ddb
                                : AppColors.xff33a752,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _selectAndNavigateToOrganization(Organization org) {
    context.read<OrganizationBloc>().add(SelectOrganization(org));
    // context.read<OrganizationBloc>().add(LoadOrganizationsRequested(org)); // ✅ Refresh home data
  }

  void _navigateToCreateOrganization() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrganizationPage(),
      ),
    );
    if (created == true) {
      _loadOrganizations();
      widget.onOrganizationCreated();
    }
  }
}
