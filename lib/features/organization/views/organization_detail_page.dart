import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_bloc.dart';
import 'package:chalan_book_app/features/organization/views/member_card.dart';
import 'package:chalan_book_app/features/organization/views/qr_scanner_page.dart';
import 'package:chalan_book_app/features/shared/widgets/format_date.dart';
import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/organization.dart';
import '../../../main.dart';

class OrganizationDetailPage extends StatefulWidget {
  final Organization organization;

  const OrganizationDetailPage({super.key, required this.organization});

  @override
  State<OrganizationDetailPage> createState() => _OrganizationDetailPageState();
}

class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrganizationBloc>().add(
      LoadOrganizationMembers(widget.organization.id),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Future<void> _sendInvite() async {
  //   final email = _emailController.text.trim().toLowerCase();
  //   if (email.isEmpty) {
  //     context.showSnackbar('Please enter an email address', isError: true);
  //     return;
  //   }

  //   setState(() => _isInviting = true);

  //   try {
  //     final email = _emailController.text.trim().toLowerCase();
  //     final orgId = widget.organization.id;

  //     if (orgId.toString().isEmpty) {
  //       throw Exception("Organization ID is missing!");
  //     }

  //     final inviteId = const Uuid().v4();
  //     await supabase.from('organization_invites').insert({
  //       'id': inviteId,
  //       'organization_id': orgId,
  //       'email': email,
  //     });

  //     context.showSnackbar('✅ Invite sent to $email');
  //     _emailController.clear();
  //   } catch (e) {
  //     context.showSnackbar('❌ Failed to send invite: $e', isError: true);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizationBloc, OrganizationState>(
      listener: (context, state) {
        if (state is OrganizationFailure) {
          context.showSnackbar(state.message ?? "", isError: true);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(widget.organization.name)),
        body: state is OrganizationLoading
            ? Center(child: CircularProgressIndicator())
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
                    
                    if (widget.organization.ownerId ==
                        Supa().currentUserId) ...[
                      const Text(
                        'Add Member',
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
                              Text(
                                'Scan QR code to add new member',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),

                              BlocBuilder<OrganizationBloc, OrganizationState>(
                                builder: (context, state) {
                                  if (state is QRScanningState) {
                                    return Column(
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 8),
                                        const Text('Ready to scan...'),
                                      ],
                                    );
                                  }

                                  if (state is AddingMemberState) {
                                    return Column(
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 8),
                                        const Text('Adding member...'),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () =>
                                              _openQRScanner(context),
                                          icon: const Icon(
                                            Icons.qr_code_scanner,
                                          ),
                                          label: const Text('Scan QR'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _selectQRFromGallery(context),
                                          icon: const Icon(Icons.image),
                                          label: const Text('From Gallery'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Members List
                    BlocBuilder<OrganizationBloc, OrganizationState>(
                      builder: (context, state) {
                        final count = state is OrganizationSuccess
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
                    BlocBuilder<OrganizationBloc, OrganizationState>(
                      builder: (context, state) {
                        if (state is OrganizationLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is OrganizationSuccess) {
                          return Column(
                            children: state.members
                                .map((m) => MemberCard(m))
                                .toList(),
                          );
                        } else if (state is OrganizationFailure) {
                          return Text(state.message ?? "");
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

  void _openQRScanner(BuildContext context) {
    context.read<OrganizationBloc>().add(ScanQRCode());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onQRCodeScanned: (qrData) {
            Navigator.pop(context);
            context.read<OrganizationBloc>().add(
              ProcessQRResult(
                qrData: qrData,
                organizationId: widget.organization.id,
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectQRFromGallery(BuildContext context) {
    context.read<OrganizationBloc>().add(SelectQRFromGallery());
  }
}
