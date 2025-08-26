import 'dart:async';

import 'package:app_links/app_links.dart'; // ✅ new package
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_bloc.dart';
import 'package:chalan_book_app/features/auth/views/reset_password_screen.dart';
import 'package:chalan_book_app/features/chalan/bloc/filter_bloc.dart';
import 'package:chalan_book_app/features/profile/bloc/profile_bloc.dart';
import 'package:chalan_book_app/services/bloc_base/bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/views/splash_page.dart';
import 'features/chalan/bloc/chalan_bloc.dart';
import 'features/organization/bloc/organization_bloc.dart';
import 'features/theme/bloc/theme_bloc.dart';

Future<void> main() async {
  Bloc.observer = const AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global Supabase client
  await Supabase.initialize(
    url: AppKeys.newSupabaseUrl,
    anonKey: AppKeys.newSupabaseAnonKey,
  );

  runApp(const MyApp());
}

// Global client (for direct use when needed)
final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    // Handle initial link (when app is launched from terminated state)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Handle incoming links while app is running
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'myapp' && uri.host == 'reset') {
      final token = uri.queryParameters['access_token'];
      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(accessToken: token),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc()),
            BlocProvider(create: (_) => ThemeBloc()..add(LoadThemeEvent())),
            BlocProvider(create: (_) => OrganizationBloc()),
            BlocProvider(
              create: (context) => ChalanBloc(
                organizationBloc: context.read<OrganizationBloc>(),
              ),
            ),
            BlocProvider(create: (_) => ProfileBloc()),
            BlocProvider(create: (_) => FilterBloc()),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                title: 'Chalan Book',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                localizationsDelegates: const [AppLocalizations.delegate],
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SplashPage(),
                debugShowCheckedModeBanner: false,
              );
            },
          ),
        );
      },
    );
  }
}
