import 'package:flutter/material.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/models/organization.dart';

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
    if (organizations.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<Organization>(
      onSelected: onOrganizationChanged,
      itemBuilder: (context) => organizations
          .map((org) => PopupMenuItem<Organization>(
                value: org,
                child: Row(
                  children: [
                    Icon(
                      org.id == currentOrganization?.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(org.name)),
                  ],
                ),
              ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentOrganization?.name ?? 'Select Org',
              style: context.textTheme.titleSmall,
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
