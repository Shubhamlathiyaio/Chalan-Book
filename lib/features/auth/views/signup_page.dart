import 'package:chalan_book_app/core/configs/gap.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_bloc.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_event.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_state.dart';
import 'package:chalan_book_app/features/shared/widgets/custom_text_field.dart';
import 'package:chalan_book_app/features/shared/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  // final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    // _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          // Show error SnackBar immediately on failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthSuccess) {
          // Show success SnackBar and navigate back on success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Check your email to confirm.')),
          );
          Navigator.pop(context); // back to LoginPage
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.signUp)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Icon(Icons.person_add, size: 80, color: Colors.blue),
                    gap.h24,

                    // Name field
                    // CustomTextField(
                    //   controller: _nameCtrl,
                    //   label: AppStrings.name,
                    //   keyboardType: TextInputType.name,
                    //   validator: (v) {
                    //     if (v == null || v.trim().isEmpty) {
                    //       return 'Enter your name';
                    //     }
                    //     return null;
                    //   },
                    // ),

                    // gap.h16,

                    // Email field
                    CustomTextField(
                      controller: _emailCtrl,
                      label: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter email';
                        }
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),

                    gap.h16,

                    // Password field
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: AppStrings.password,
                      obscureText: true,
                      validator: (v) =>
                          v != null && v.length >= 6 ? null : 'Min 6 chars',
                    ),
                    gap.h24,

                    LoadingButton(
                      text: AppStrings.signUp,
                      isLoading: isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthSignupRequested(
                              // name: _nameCtrl.text.trim(),
                              email: _emailCtrl.text.trim(),
                              password: _passwordCtrl.text.trim(),
                            ),
                          );
                        }
                      },
                    ),

                    gap.h16,

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.alreadyHaveAccount),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
