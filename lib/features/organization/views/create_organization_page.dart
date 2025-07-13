import 'package:chalan_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/organization/organization_bloc.dart';
import '../../../bloc/organization/organization_event.dart';
import '../../../bloc/organization/organization_state.dart';
import '../../../core/constants/strings.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    context.read<OrganizationBloc>().add(
          CreateOrganizationRequested(name: name, description: desc),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createOrganization)),
      body: BlocConsumer<OrganizationBloc, OrganizationState>(
        listener: (context, state) {
          if (state is OrganizationFailure) {
            context.showSnackBar('❌ ${state.message}', isError: true);
          }
          context.showSnackBar('✅ Organization created successfully!');
            Navigator.pop(context, true);
        },
        builder: (context, state) {
          final isLoading = state is OrganizationLoading;

          return Padding(
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      onPressed: _submit,
                      isLoading: isLoading,
                      text: 'Create Organization',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
