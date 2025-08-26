import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

SizedBox gap = const SizedBox();

extension SuperBox on SizedBox {
  //==============================================================================
  //     **   Gap For All Side Space  **
  //==============================================================================

  SizedBox allF([double no = 5]) => SizedBox(height: no.h, width: no.w);
  SizedBox get all => allF(5);
  SizedBox get all8 => allF(8);
  SizedBox get all10 => allF(10);
  SizedBox get all12 => allF(12);
  SizedBox get all15 => allF(15);
  SizedBox get all16 => allF(16);
  SizedBox get all20 => allF(20);
  SizedBox get all24 => allF(24);
  SizedBox get all32 => allF(32);
  SizedBox get all40 => allF(40);
  SizedBox get all48 => allF(48);
  SizedBox get all80 => allF(80);
  SizedBox get all96 => allF(96);
  SizedBox get all180 => allF(180);
  SizedBox get allInf => allF(double.infinity);

  //==============================================================================
  //     **   Gap For Vertical Space  **
  //==============================================================================

  SizedBox hf([double no = 5]) => SizedBox(height: no.h);

  SizedBox get zero => hf(0);
  SizedBox get h4 => hf(4);
  SizedBox get h => hf(5);
  SizedBox get h8 => hf(8);
  SizedBox get h10 => hf(10);
  SizedBox get h12 => hf(12);
  SizedBox get h15 => hf(15);
  SizedBox get h16 => hf(16);
  SizedBox get h20 => hf(20);
  SizedBox get h24 => hf(24);
  SizedBox get h32 => hf(32);
  SizedBox get h40 => hf(40);
  SizedBox get h48 => hf(48);
  SizedBox get h80 => hf(80);
  SizedBox get h96 => hf(96);
  SizedBox get h180 => hf(180);
  SizedBox get hInf => hf(double.infinity);

  //==============================================================================
  //     **   Gap For Horizontal Space  **
  //==============================================================================

  SizedBox wf([double no = 5]) => SizedBox(width: no.h);

  SizedBox get w => wf(5);
  SizedBox get w8 => wf(8);
  SizedBox get w10 => wf(10);
  SizedBox get w15 => wf(15);
  SizedBox get w16 => wf(16);
  SizedBox get w20 => wf(20);
  SizedBox get w22 => wf(22);
  SizedBox get wInf => wf(double.infinity);
}
