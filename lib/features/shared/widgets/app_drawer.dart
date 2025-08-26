import 'package:chalan_book_app/services/auth_services.dart';
import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/extensions/context_extension.dart';
import '../../auth/views/splash_page.dart';
import '../../theme/bloc/theme_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final supa = Supa();
    final user = supa.currentUser;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: context.colors.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: context.colors.primary,
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'User',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Chalans'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Organizations'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return SwitchListTile(
                      secondary: Icon(
                        state.themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      title: const Text('Dark Mode'),
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
