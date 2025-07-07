import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants.dart';
import '../../../main.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';

class CreateOrganizationPage extends StatefulWidget {
  const CreateOrganizationPage({super.key});

  @override
  State<CreateOrganizationPage> createState() => _CreateOrganizationPageState();
}

class _CreateOrganizationPageState extends State<CreateOrganizationPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createOrganization() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final orgName = _nameController.text.trim();

    // ✅ 1. Check if organization name already exists
    final existing = await supabase
        .from(organizationsTable)
        .select('id')
        .eq('name', orgName)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Organization name already exists');
    }

    final organizationId = const Uuid().v4();
    final userId = user.id;

    // ✅ 2. Insert the organization
    await supabase.from(organizationsTable).insert({
      'id': organizationId,
      'name': orgName,
      'owner_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // ✅ 3. Add user to organization_users
    await supabase.from(organizationUsersTable).insert({
      'id': const Uuid().v4(),
      'organization_id': organizationId,
      'user_id': userId,
      'email': user.email,
      'role': 'admin',
      'joined_at': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      context.showSnackBar('✅ Organization created successfully!');
      Navigator.pop(context, true);
    }
  } catch (error) {
    if (mounted) {
      context.showSnackBar('❌ Error: $error', isError: true);
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createOrganization)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.business, size: 64, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Create New Organization',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your organization to start managing chalans',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.organizationName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  onPressed: _createOrganization,
                  isLoading: _isLoading,
                  text: 'Create Organization',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}