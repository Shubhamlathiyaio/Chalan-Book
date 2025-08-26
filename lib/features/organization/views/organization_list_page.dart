import 'package:chalan_book_app/core/configs/app_typography.dart';
import 'package:chalan_book_app/core/constants/app_colors.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_bloc.dart';
import 'package:chalan_book_app/features/organization/views/create_organization_page.dart';
import 'package:chalan_book_app/features/organization/views/organization_detail_page.dart';
import 'package:chalan_book_app/features/shared/widgets/empty_state.dart';
import 'package:chalan_book_app/features/shared/widgets/format_date.dart';
import 'package:chalan_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrganizationListPage extends StatefulWidget {
  const OrganizationListPage({super.key});

  @override
  State<OrganizationListPage> createState() => _OrganizationListPageState();
}

class _OrganizationListPageState extends State<OrganizationListPage> {
  // final supa = Supa();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizationBloc, OrganizationState>(
      builder: (context, state) {
        if (state is OrganizationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrganizationError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state.organizations.isEmpty) {
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
                      'Organizations (${state.organizations.length})',
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
                itemCount: state.organizations.length,
                itemBuilder: (context, index) {
                  final org = state.organizations[index];
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
                              if (org.description != null)
                                Text(org.description ?? ""),
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
      },
    );
  }

  void _selectAndNavigateToOrganization(Organization org) {
    context.read<OrganizationBloc>().add(SelectOrganization(org));
  }

  void _navigateToCreateOrganization() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateOrganizationPage(
          );
        },
      ),
    );
  }
}
