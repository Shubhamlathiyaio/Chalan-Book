import 'package:chalan_book_app/bloc/organization_invite/organization_invite_bloc.dart';
import 'package:chalan_book_app/bloc/organization_invite/organization_invite_event.dart';
import 'package:chalan_book_app/bloc/organization_invite/organization_invite_state.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/features/organization/views/member_card.dart';
import 'package:chalan_book_app/shared/widgets/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/organization.dart';
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
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    context.read<OrganizationInviteBloc>().add(
      LoadOrganizationMembers(widget.organization.id),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      context.showSnackBar('Please enter an email address', isError: true);
      return;
    }

    setState(() => _isInviting = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      final orgId = widget.organization.id;

      if (orgId.toString().isEmpty) {
        throw Exception("Organization ID is missing!");
      }

      final inviteId = const Uuid().v4();
      await supabase.from('organization_invites').insert({
        'id': inviteId,
        'organization_id': orgId,
        'email': email,
      });

      context.showSnackBar('✅ Invite sent to $email');
      _emailController.clear();
    } catch (e) {
      context.showSnackBar('❌ Failed to send invite: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizationInviteBloc, OrganizationInviteState>(
      listener: (context, state) {
        if (state is OrganizationInviteFailure) {
          context.showSnackBar(state.message, isError: true);
        } else if (state is OrganizationInviteSent) {
          context.showSnackBar('✅ Invite sent successfully!');
        }
      },builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(widget.organization.name)),
        body:  state is OrganizationInviteLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.organization.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (widget.organization.description !=
                                            null)
                                          Text(
                                            widget.organization.description!,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        Text(
                                          'Created ${formatDate(widget.organization.createdAt)}',
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                                  onPressed: _sendInvite,
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
                      BlocBuilder<
                        OrganizationInviteBloc,
                        OrganizationInviteState
                      >(
                        builder: (context, state) {
                          final count = state is OrganizationInviteSuccess
                              ? state.members.length
                              : 0;
                          return Text(
                            'Members ($count)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),
                      BlocBuilder<
                        OrganizationInviteBloc,
                        OrganizationInviteState
                      >(
                        builder: (context, state) {
                          if (state is OrganizationInviteLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is OrganizationInviteSuccess) {
                            return Column(
                              children: state.members
                                  .map((m) => MemberCard(m))
                                  .toList(),
                            );
                          } else if (state is OrganizationInviteFailure) {
                            return Text(state.message);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
      
      ),
    );
  }
}
