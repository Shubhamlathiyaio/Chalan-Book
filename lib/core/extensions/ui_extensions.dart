import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Gap Extensions
SizedBox gap = const SizedBox();

extension SuperBox on SizedBox {
  SizedBox hf([double no = 5]) => SizedBox(height: no.h);
  SizedBox wf([double no = 5]) => SizedBox(width: no.w);

  SizedBox get h4 => hf(4);
  SizedBox get h8 => hf(8);
  SizedBox get h12 => hf(12);
  SizedBox get h16 => hf(16);
  SizedBox get h20 => hf(20);
  SizedBox get h24 => hf(24);

  SizedBox get w8 => wf(8);
  SizedBox get w12 => wf(12);
  SizedBox get w16 => wf(16);
  SizedBox get w20 => wf(20);
  SizedBox get w24 => wf(24);
}

// EdgeInsets Extensions
extension SuperEdgeInsets on EdgeInsets {
  EdgeInsets allF(double value) => EdgeInsets.all(value.w);
  EdgeInsets hf(double value) => EdgeInsets.symmetric(horizontal: value.w);
  EdgeInsets vf(double value) => EdgeInsets.symmetric(vertical: value.h);

  EdgeInsets get all8 => allF(8);
  EdgeInsets get all12 => allF(12);
  EdgeInsets get all16 => allF(16);
  EdgeInsets get all20 => allF(20);
  EdgeInsets get all24 => allF(24);

  EdgeInsets get h8 => hf(8);
  EdgeInsets get h12 => hf(12);
  EdgeInsets get h16 => hf(16);
  EdgeInsets get h20 => hf(20);

  EdgeInsets get v8 => vf(8);
  EdgeInsets get v12 => vf(12);
  EdgeInsets get v16 => vf(16);
  EdgeInsets get v20 => vf(20);
}

// BorderRadius Extensions
extension SuperRadius on BorderRadius {
  BorderRadius allF(double value) => BorderRadius.circular(value.r);

  BorderRadius get all8 => allF(8);
  BorderRadius get all12 => allF(12);
  BorderRadius get all16 => allF(16);
  BorderRadius get all20 => allF(20);
  BorderRadius get all24 => allF(24);
}
