import 'package:chalan_book_app/core/models/organization_member.dart';
import 'package:chalan_book_app/features/shared/widgets/format_date.dart';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final OrganizationMember member;
  const MemberCard( this.member,{ super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.role == 'admin' ? Colors.orange : Colors.blue,
          child: Icon(
            member.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(member.email),
        subtitle: Text(
          '${member.role.toUpperCase()} • Joined ${formatDate(member.joinedAt)}',
        ),
        trailing: member.role == 'admin'
            ? Chip(
                label: const Text('Admin'),
                backgroundColor: Colors.orange.withOpacity(0.2),
              )
            : null,
      ),
    );
  }
}


