import 'package:chalan_book_app/bloc/auth/auth_bloc.dart';
import 'package:chalan_book_app/bloc/auth/auth_event.dart';
import 'package:chalan_book_app/bloc/auth/auth_state.dart';
import 'package:chalan_book_app/bloc/organization/organization_bloc.dart';
import 'package:chalan_book_app/bloc/organization/organization_event.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/features/auth/views/signup_page.dart';
import 'package:chalan_book_app/features/home/views/home_page.dart';
import 'package:chalan_book_app/shared/widgets/custom_text_field.dart';
import 'package:chalan_book_app/shared/widgets/loading_button.dart';
import 'package:chalan_book_app/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (_, state) {
              if (state is AuthSuccess) {
                context.pushReplacement(
                  BlocProvider(
                    create: (_) => OrganizationBloc()..add(LoadOrganizationsRequested()),
                    child: const HomePage(),
                  ),
                );
              }
              if (state is AuthFailure) (msg) => context.showSnackbar(msg);
            },
            builder: (_, state) {
              final loading = state is AuthLoading;

              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const _Header(),
                    const SizedBox(height: 48),
                    _EmailField(ctrl: _emailCtrl),
                    const SizedBox(height: 16),
                    _PassField(ctrl: _passCtrl),
                    const SizedBox(height: 24),
                    LoadingButton(
                      text: AppStrings.login,
                      isLoading: loading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthLoginRequested(
                              email: _emailCtrl.text.trim(),
                              password: _passCtrl.text,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push(const SignupPage()),
                      child: Text(AppStrings.dontHaveAccount),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),    
    );
  }
}

/* ---------------- small stateless helpers ---------------- */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Icon(Icons.receipt_long, size: 80, color: Colors.blue),
      const SizedBox(height: 24),
      Text(
        AppStrings.appName,
        style: context.h1.copyWith(color: Colors.blue),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        'Welcome back!',
        style: context.body2.copyWith(color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: ctrl,
    label: AppStrings.email,
    keyboardType: TextInputType.emailAddress,
    validator: (v) => v == null || v.isEmpty
        ? 'Enter email'
        : v.contains('@')
        ? null
        : 'Invalid email',
  );
}

class _PassField extends StatelessWidget {
  const _PassField({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: ctrl,
    label: AppStrings.password,
    obscureText: true,
    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
  );
}
