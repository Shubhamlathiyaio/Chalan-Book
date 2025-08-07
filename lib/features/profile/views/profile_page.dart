import 'package:chalan_book_app/features/auth/views/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/extensions/context_extension.dart';
import '../../theme/bloc/theme_bloc.dart';
import '../../../main.dart';

// Event
abstract class ProfileEvent {}

class ProfileLoaded extends ProfileEvent {
  final User user;
  ProfileLoaded(this.user);
}

class ToggleEditingEvent extends ProfileEvent {}

// State
class ProfileState {
  final String userName;
  final bool isEditing;
  const ProfileState({this.userName = '', this.isEditing = false});

  ProfileState copyWith({String? userName, bool? isEditing}) {
    return ProfileState(
      userName: userName ?? this.userName,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<ToggleEditingEvent>(_onToggleEditing);
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    final user = event.user;
    emit(
      state.copyWith(
        // user: user,
      ),
    );
  }

  Future<void> _onToggleEditing(
    ToggleEditingEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isEditing: !state.isEditing));
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    _nameController.text = user?.userMetadata?['name'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

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
                              icon: Icon(state.isEditing ? Icons.close : Icons.edit),
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
                              onPressed: _saveProfile,
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
                            state.themeMode==ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                          ),
                          title: Text(
                            state.themeMode==ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                          ),
                          subtitle: Text(
                            state.themeMode==ThemeMode.dark ? 'Dark theme enabled' : 'Light theme enabled',
                          ),
                          value: state.themeMode==ThemeMode.dark,
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
         
            
            // Log Out Button
            ElevatedButton(
              onPressed: () async {
                await supabase.auth.signOut();
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

  Future<void> _saveProfile() async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'name': _nameController.text.trim()},
        ),
      );
      
      context.read<ProfileBloc>().add(
        ToggleEditingEvent(),
      );
      context.showSnackbar('Profile updated successfully!');
    } catch (e) {
      context.showSnackbar('Error updating profile: $e', isError: true);
    }
  }
}

