import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

SizedBox gap = const SizedBox();

extension SuperBox on SizedBox {
  //==============================================================================
  //     **   Gap For Vertical Space  **
  //==============================================================================

  SizedBox hf([double no = 5]) => SizedBox(height: no.h);

  SizedBox get zero => hf(0);
  SizedBox get h => hf(5);
  SizedBox get h8 => hf(8);
  SizedBox get h10 => hf(10);
  SizedBox get h12 => hf(12);
  SizedBox get h15 => hf(15);
  SizedBox get h16 => hf(16);
  SizedBox get h20 => hf(20);
  SizedBox get h24 => hf(24);
  SizedBox get h40 => hf(40);
  SizedBox get h48 => hf(48);
  SizedBox get h80 => hf(80);
  SizedBox get h96 => hf(96);
  SizedBox get h180 => hf(180);
  SizedBox get hm => hf(double.infinity);

  //==============================================================================
  //     **   Gap For Horizontal Space  **
  //==============================================================================

  SizedBox wf([double no = 5]) => SizedBox(width: no.h);

  SizedBox get w => wf(5);
  SizedBox get w10 => wf(10);
  SizedBox get w15 => wf(15);
  SizedBox get w16 => wf(16);
  SizedBox get w20 => wf(20);
  SizedBox get w22 => wf(22);
  SizedBox get wm => wf(double.infinity);
}
