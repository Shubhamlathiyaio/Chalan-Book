// import 'package:chalan_book_app/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// TextStyle roboto = const TextStyle(fontFamily: FontFamily.roboto);
// TextStyle raleway = const TextStyle(fontFamily: FontFamily.raleway);
// TextStyle poppins = const TextStyle(fontFamily: FontFamily.poppins);
// TextStyle redRose = const TextStyle(fontFamily: FontFamily.redRose);

// class FontFamily {
//   static const String poppins = 'Poppins';
//   static const String redRose = 'RedRose';
//   static const String raleway = 'Raleway';
//   static const String roboto = 'Roboto';
// }

// extension TextStyleExtensions on TextStyle {
//   /// Font Size
//   /// This method calculates the font size based on the height and width of the screen.
//   TextStyle size(double v) => copyWith(fontSize: ( v.sp  )); //+ (v.w)*.1
//   TextStyle get fs1 => size(01);
//   TextStyle get fs2 => size(02);
//   TextStyle get fs3 => size(03);
//   TextStyle get fs4 => size(04);
//   TextStyle get fs5 => size(05);
//   TextStyle get fs6 => size(06);
//   TextStyle get fs7 => size(07);
//   TextStyle get fs8 => size(08);
//   TextStyle get fs9 => size(09);
//   TextStyle get fs10 => size(10);
//   TextStyle get fs11 => size(11);
//   TextStyle get fs12 => size(12);
//   TextStyle get fs13 => size(13);
//   TextStyle get fs14 => size(14);
//   TextStyle get fs15 => size(15);
//   TextStyle get fs16 => size(16);
//   TextStyle get fs17 => size(17);
//   TextStyle get fs18 => size(18);
//   TextStyle get fs19 => size(19);
//   TextStyle get fs20 => size(20);
//   TextStyle get fs21 => size(21);
//   TextStyle get fs22 => size(22);
//   TextStyle get fs23 => size(23);
//   TextStyle get fs24 => size(24);
//   TextStyle get fs25 => size(25);
//   TextStyle get fs26 => size(26);
//   TextStyle get fs27 => size(27);
//   TextStyle get fs28 => size(28);
//   TextStyle get fs29 => size(29);
//   TextStyle get fs30 => size(30);
//   TextStyle get fs31 => size(31);
//   TextStyle get fs32 => size(32);
//   TextStyle get fs33 => size(33);
//   TextStyle get fs34 => size(34);
//   TextStyle get fs35 => size(35);
//   TextStyle get fs36 => size(36);
//   TextStyle get fs37 => size(37);
//   TextStyle get fs38 => size(38);
//   TextStyle get fs39 => size(39);
//   TextStyle get fs40 => size(40);
//   TextStyle get fs41 => size(41);
//   TextStyle get fs42 => size(42);
//   TextStyle get fs43 => size(43);
//   TextStyle get fs44 => size(44);
//   TextStyle get fs45 => size(45);
//   TextStyle get fs46 => size(46);
//   TextStyle get fs47 => size(47);
//   TextStyle get fs48 => size(48);
//   TextStyle get fs49 => size(49);
//   TextStyle get fs50 => size(50);
//   TextStyle get fs56 => size(56);

//   /// FontWeight
//   TextStyle weight(FontWeight v) => copyWith(fontWeight: v);
//   TextStyle get w100 => weight(FontWeight.w100);
//   TextStyle get w200 => weight(FontWeight.w200);
//   TextStyle get w300 => weight(FontWeight.w300);
//   TextStyle get w400 => weight(FontWeight.w400); // Regular, Normal
//   TextStyle get w500 => weight(FontWeight.w500); // Medium
//   TextStyle get w600 => weight(FontWeight.w600);
//   TextStyle get w700 => weight(FontWeight.w700); // Bold
//   TextStyle get w800 => weight(FontWeight.w800);
//   TextStyle get w900 => weight(FontWeight.w900);

//   /// Text Color
//   TextStyle textColor(Color v) => copyWith(color: v);
//   TextStyle get white => textColor(AppColors.white);
//   TextStyle get black => textColor(AppColors.black);
//   TextStyle get primary => textColor(AppColors.primary);
//   TextStyle get error => textColor(AppColors.error);

//   /// Letter Space
//   TextStyle letterSpace(double v) => copyWith(letterSpacing: v);
//   TextStyle get s_02 => letterSpace(-0.2);
//   TextStyle get s01 => letterSpace(0.1);
//   TextStyle get s02 => letterSpace(0.2);
//   TextStyle get s03 => letterSpace(0.3);
//   TextStyle get s04 => letterSpace(0.4);
//   TextStyle get s05 => letterSpace(0.5);
//   TextStyle get s06 => letterSpace(0.6);
//   TextStyle get s07 => letterSpace(0.7);
//   TextStyle get s08 => letterSpace(0.8);
//   TextStyle get s09 => letterSpace(0.9);
//   TextStyle get s10 => letterSpace(1.0);
//   TextStyle get s11 => letterSpace(1.1);
//   TextStyle get s12 => letterSpace(1.2);
//   TextStyle get s13 => letterSpace(1.3);
//   TextStyle get s14 => letterSpace(1.4);
//   TextStyle get s15 => letterSpace(1.5);
//   TextStyle get s16 => letterSpace(1.6);
//   TextStyle get s17 => letterSpace(1.7);
//   TextStyle get s18 => letterSpace(1.8);
//   TextStyle get s19 => letterSpace(1.9);
//   TextStyle get s20 => letterSpace(2.0);

//   /// TextHeight
//   TextStyle textHeight(double v) => copyWith(height: v, background: Paint());

//   /// Text Decoration
//   TextStyle textDecoration(TextDecoration v) => copyWith(decoration: v);

//   /// Decoration Color
//   TextStyle decorationColor(Color v) => copyWith(decorationColor: v);

//   /// Text Decoration Color
//   TextStyle textDecorationColor(Color color) =>
//       copyWith(decorationColor: color);

//   /// Custom TextStyle
//   TextStyle customStyle({
//     double? letterSpacing,
//     double? fontSize,
//     FontWeight? weight,
//   }) => copyWith(
//     letterSpacing: letterSpacing,
//     fontSize: fontSize,
//     fontWeight: weight,
//   );
// }
