import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

// Font families
TextStyle poppins = const TextStyle(fontFamily: 'Poppins');
TextStyle roboto = const TextStyle(fontFamily: 'Roboto');
TextStyle raleway = const TextStyle(fontFamily: 'Raleway');

extension TextStyleExtensions on TextStyle {
  // Font Size
  TextStyle size(double v) => copyWith(fontSize: v.sp);
  TextStyle get fs10 => size(10);
  TextStyle get fs11 => size(11);
  TextStyle get fs12 => size(12);
  TextStyle get fs14 => size(14);
  TextStyle get fs16 => size(16);
  TextStyle get fs18 => size(18);
  TextStyle get fs20 => size(20);
  TextStyle get fs22 => size(22);
  TextStyle get fs24 => size(24);
  TextStyle get fs28 => size(28);
  TextStyle get fs32 => size(32);
  TextStyle get fs36 => size(36);
  TextStyle get fs48 => size(48);
  TextStyle get fs56 => size(56);

  // Font Weight
  TextStyle weight(FontWeight v) => copyWith(fontWeight: v);
  TextStyle get w400 => weight(FontWeight.w400); // Regular
  TextStyle get w500 => weight(FontWeight.w500); // Medium
  TextStyle get w600 => weight(FontWeight.w600); // SemiBold
  TextStyle get w700 => weight(FontWeight.w700); // Bold

  // Text Color
  TextStyle textColor(Color v) => copyWith(color: v);
  TextStyle get white => textColor(AppColors.white);
  TextStyle get black => textColor(AppColors.black);
  TextStyle get primary => textColor(AppColors.primary);
  TextStyle get error => textColor(AppColors.error);

  // Letter Spacing
  TextStyle letterSpace(double v) => copyWith(letterSpacing: v);
  TextStyle get s02 => letterSpace(0.2);
  TextStyle get s05 => letterSpace(0.5);
}
