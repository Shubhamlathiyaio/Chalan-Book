import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/features/auth/bloc/auth_bloc.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                ],
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
