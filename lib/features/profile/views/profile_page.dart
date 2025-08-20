import 'dart:io';

import 'package:chalan_book_app/features/auth/views/splash_page.dart';
import 'package:chalan_book_app/features/profile/bloc/profile_bloc.dart';
import 'package:chalan_book_app/services/auth_services.dart';
import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/extensions/context_extension.dart';
import '../../theme/bloc/theme_bloc.dart';
import '../../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supa = Supa();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = supa.currentUser;
    _nameController.text = user?.userMetadata?['name'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = supa.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: context.colors.primary,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Profile Info Card
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Profile Information',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                context.read<ProfileBloc>().add(
                                  ToggleEditingEvent(),
                                );
                              },
                              icon: Icon(
                                state.isEditing ? Icons.close : Icons.edit,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          enabled: state.isEditing,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Email Field (Read-only)
                        TextFormField(
                          initialValue: user?.email ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        if (state.isEditing) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: null, //_saveProfile,
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Settings Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Theme Toggle
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: Icon(
                            state.themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          title: Text(
                            state.themeMode == ThemeMode.dark
                                ? 'Light Mode'
                                : 'Dark Mode',
                          ),
                          subtitle: Text(
                            state.themeMode == ThemeMode.dark
                                ? 'Dark theme enabled'
                                : 'Light theme enabled',
                          ),
                          value: state.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(ToggleThemeEvent());
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // QR Code Card (add this after the Settings Card)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Identity',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is your unique QR code that you can use to enter in others Organization.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Code
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: user?.id ?? '',
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Share Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _shareQRCode(user?.id),
                        icon: const Icon(Icons.share),
                        label: const Text('Share QR Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Log Out Button
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SplashPage()),
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _saveProfile() async {
  //   try {
  //     await supa.updateUser(
  //       UserAttributes(data: {'name': _nameController.text.trim()}),
  //     );

  //     context.read<ProfileBloc>().add(ToggleEditingEvent());
  //     context.showSnackbar('Profile updated successfully!');
  //   } catch (e) {
  //     context.showSnackbar('Error updating profile: $e', isError: true);
  //   }
  // }

  Future<void> _shareQRCode(String? userId) async {
    if (userId == null) return;

    try {
      // Generate QR code as image
      final qrValidationResult = QrValidator.validate(
        data: userId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        context.showSnackbar('Invalid QR code data', isError: true);
        return;
      }

      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      // Create image from QR code
      final picData = await painter.toImageData(400);
      if (picData == null) {
        context.showSnackbar('Failed to generate QR code', isError: true);
        return;
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/organization_invite_qr.png');
      await file.writeAsBytes(picData.buffer.asUint8List());

      // Share the QR code
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      print('Error sharing QR code: $e');
      context.showSnackbar('Error sharing QR code', isError: true);
    }
  }
}
