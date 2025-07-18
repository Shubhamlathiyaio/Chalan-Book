import 'package:chalan_book_app/bloc/advanced_filter/advanced_filter_bloc.dart';
import 'package:chalan_book_app/bloc/auth/auth_bloc.dart';
import 'package:chalan_book_app/bloc/chalan/chalan_bloc.dart';
import 'package:chalan_book_app/bloc/nav_bar_cubit.dart';
import 'package:chalan_book_app/bloc/organization/organization_bloc.dart';
import 'package:chalan_book_app/bloc/organization_invite/organization_invite_bloc.dart';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/views/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

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
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  );
  }
}

// We will rename a to aBlocProviders for clarity
final blocProviders = [
  BlocProvider<NavBarCubit>(create: (_) => NavBarCubit()),
  BlocProvider<OrganizationBloc>(create: (context) => OrganizationBloc()),
  BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
  BlocProvider<ChalanBloc>(create: (context) => ChalanBloc(organizationBloc: context.read<OrganizationBloc>())),
  BlocProvider<AdvancedChalanFilterBloc>(create: (context) => AdvancedChalanFilterBloc()),
  BlocProvider<OrganizationInviteBloc>(
    create: (context) => OrganizationInviteBloc(),
  ),
];

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Colors.green,
      ),
    );
  }
}
