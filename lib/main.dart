import 'package:chalan_book_app/features/auth/auth/auth_bloc.dart';
import 'package:chalan_book_app/features/chalan/bloc/filter_bloc.dart';
import 'package:chalan_book_app/features/organization/bloc/organization_invite/organization_invite_bloc.dart';
import 'package:chalan_book_app/features/profile/views/profile_page.dart';
import 'package:chalan_book_app/services/bloc_base/bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_keys.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/views/splash_page.dart';
import 'features/chalan/bloc/chalan_bloc.dart';
import 'features/organization/bloc/organization_bloc.dart';
import 'features/theme/bloc/theme_bloc.dart';

Future<void> main() async {
  Bloc.observer = const AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppKeys.supabaseUrl,
    anonKey: AppKeys.supabaseAnonKey,
  );

  runApp(const MyApp());
}

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
              create: (context) => ChalanBloc(organizationBloc: context.read<OrganizationBloc>(),
              ),
            ),
            BlocProvider(create: (_) => OrganizationInviteBloc()),
            BlocProvider(create: (_) => ProfileBloc()),
            BlocProvider(create: (_) => OrganizationInviteBloc()),
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
                  // GlobalMaterialLocalizations.delegate,
                  // GlobalWidgetsLocalizations.delegate,
                  // GlobalCupertinoLocalizations.delegate,
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
