import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants.dart';
import '../../../core/models/organization.dart';
import '../../../core/models/organization_member.dart';
import '../../../main.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';

class OrganizationDetailPage extends StatefulWidget {
  final Organization organization;

  const OrganizationDetailPage({super.key, required this.organization});

  @override
  State<OrganizationDetailPage> createState() => _OrganizationDetailPageState();
}

class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  final _emailController = TextEditingController();
  List<OrganizationMember> _members = [];
  bool _isLoading = true;
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _loadMembers() async {
    try {
      final response = await supabase
          .from(organizationUsersTable)
          .select('*, profiles:user_id(email)')
          .eq('organization_id', widget.organization.id);

      final members = response.map((item) {
        return OrganizationMember(
          id: item['id'],
          organizationId: item['organization_id'],
          userId: item['user_id'],
          email: item['profiles']?['email'] ?? 'Unknown',
          role: item['role'],
          joinedAt: DateTime.parse(item['joined_at']),
        );
      }).toList();

      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showSnackBar('Error loading members: $error', isError: true);
      }
    }
  }

  void _inviteMember() async {
    if (_emailController.text.trim().isEmpty) {
      context.showSnackBar('Please enter an email address', isError: true);
      return;
    }

    setState(() => _isInviting = true);

    try {
      // Check if user already exists as member
      final existingMember = _members.any(
        (member) =>
            member.email.toLowerCase() ==
            _emailController.text.trim().toLowerCase(),
      );

      if (existingMember) {
        throw Exception('User is already a member of this organization');
      }

      // For now, we'll add the member directly
      // In a real app, you'd send an invitation email
      await supabase.from(organizationUsersTable).insert({
        'id': const Uuid().v4(),
        'organization_id': widget.organization.id,
        'user_id': '', // This would be filled when user accepts invitation
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });

      _emailController.clear();
      _loadMembers();

      if (mounted) {
        context.showSnackBar('Member invited successfully!');
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Error inviting member: $error', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isInviting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.organization.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 30,
                                child: Text(
                                  widget.organization.name
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.organization.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.organization.description != null)
                                      Text(
                                        widget.organization.description!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    Text(
                                      'Created ${_formatDate(widget.organization.createdAt)}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add Member Section
                  const Text(
                    AppStrings.addMember,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            label: AppStrings.memberEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: LoadingButton(
                              onPressed: _inviteMember,
                              isLoading: _isInviting,
                              text: AppStrings.invite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Members List
                  Text(
                    'Members (${_members.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._members.map(
                    (member) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: member.role == 'admin'
                              ? Colors.orange
                              : Colors.blue,
                          child: Icon(
                            member.role == 'admin'
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(member.email),
                        subtitle: Text(
                          '${member.role.toUpperCase()} • Joined ${_formatDate(member.joinedAt)}',
                        ),
                        trailing: member.role == 'admin'
                            ? Chip(
                                label: const Text('Admin'),
                                backgroundColor: Colors.orange.withOpacity(0.2),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}