import 'package:chalan_book_app/core/constants/app_colors.dart';
import 'package:chalan_book_app/theme/text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.bgOfLight,
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: AppColors.primary,
    splashColor: AppColors.splash,
    disabledColor: AppColors.grey,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondaryOfLight,
      onSecondary: AppColors.onSurfaceOfLight,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.surfaceOfLight,
      onSurface: AppColors.secondaryOfLight,
      // tertiary: AppColors.textFieldLableOfLight
    ),
    textTheme: AppTextTheme.appTextThemeLight,
  );

  // ThemeData darkTheme = ThemeData(
  //   scaffoldBackgroundColor: AppColors.bgOfDark,
  //   brightness: Brightness.dark,
  //   useMaterial3: true,
  //   splashColor: AppColors.splash,
  //   disabledColor: AppColors.grey,
  //   primaryColor: AppColors.primary,
  //   inputDecorationTheme: InputDecorationTheme(
  //     hintStyle: roboto.w600.fs20.textColor(AppColors.textFieldLableOfDark),
  //   ),
  //   colorScheme: ColorScheme(
  //     brightness: Brightness.dark,
  //     primary: AppColors.primary,
  //     onPrimary: AppColors.white,
  //     secondary: AppColors.secondaryOfDark,
  //     onSecondary: AppColors.black,
  //     error: AppColors.error,
  //     onError: AppColors.white,
  //     surface: AppColors.surfaceOfDark,
  //     onSurface: AppColors.grayA5OfDark,
  //   ),
  //   textTheme: TextTheme(
  //     bodySmall: roboto.w400.fs12.textColor(AppColors.grayA5OfDark),
  //     displayLarge: roboto.w600.fs18.primary,
  //     labelLarge: roboto.w600.fs20.textColor(AppColors.textFieldLableOfDark),
  //     labelMedium: roboto.w600.fs14.textColor(AppColors.grayA5OfDark),
  //     labelSmall: roboto.w600.fs12.textColor(AppColors.grayA5OfDark),
  //   ),
  // );
}
