// signup_page.dart
import 'package:chalan_book_app/bloc/auth/auth_bloc.dart';
import 'package:chalan_book_app/bloc/auth/auth_event.dart';
import 'package:chalan_book_app/bloc/auth/auth_state.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/shared/widgets/custom_text_field.dart';
import 'package:chalan_book_app/shared/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Check your email to confirm.')),
          );
          Navigator.pop(context); // back to LoginPage
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.signUp)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return ListView(
                    children: [
                      const Icon(Icons.person_add,
                          size: 80, color: Colors.blue),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordCtrl,
                        label: AppStrings.password,
                        obscureText: true,
                        validator: (v) =>
                            v != null && v.length >= 6 ? null : 'Min 6 chars',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmCtrl,
                        label: AppStrings.confirmPassword,
                        obscureText: true,
                        validator: (v) =>
                            v == _passwordCtrl.text ? null : 'Passwords differ',
                      ),
                      const SizedBox(height: 24),
                      LoadingButton(
                        text: AppStrings.signUp,
                        isLoading: isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthSignupRequested(
                                    email: _emailCtrl.text.trim(),
                                    password: _passwordCtrl.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.alreadyHaveAccount),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
