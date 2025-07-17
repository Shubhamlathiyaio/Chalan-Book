import 'package:chalan_book_app/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import '../../core/models/organization.dart';

class OrganizationSelector extends StatelessWidget {
  final List<Organization> organizations;
  final Organization? currentOrganization;
  final Function(Organization) onOrganizationChanged;

  const OrganizationSelector({
    super.key,
    required this.organizations,
    required this.currentOrganization,
    required this.onOrganizationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Organization>(
      onSelected: onOrganizationChanged,
      itemBuilder: (context) => organizations
          .map(
            (org) => PopupMenuItem<Organization>(
              value: org,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.theme.primaryColor,
                    radius: 12,
                    child: Text(
                      org.name[0].toUpperCase(),
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      org.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (org.id == currentOrganization?.id)
                    const Icon(Icons.check, color: Colors.blue, size: 16),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentOrganization != null) ...[
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 10,
                child: Text(
                  currentOrganization!.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  currentOrganization!.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ] else ...[
              const Icon(Icons.business, size: 16),
              const SizedBox(width: 8),
              const Text('Select Org', style: TextStyle(fontSize: 14)),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}