import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//==============================================================================
//                   🌟  SuperEdgeInsets Extension  🌟
//==============================================================================

final edge = EdgeInsets.zero;

extension SuperEdgeInsets on EdgeInsets {
  //----------------------------------------------------------------------------
  //  INTERNAL – merge current insets with new values (chain‑friendly)
  //----------------------------------------------------------------------------
  EdgeInsets _merge({
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? this.left,
      right: right ?? this.right,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
    );
  }

  //============================================================================
  //     **   EdgeInsets From Horizontal  **
  //============================================================================
  EdgeInsets hf(double value) => _merge(left: value.w, right: value.w);
  EdgeInsets get h2 => hf(2);
  EdgeInsets get h4 => hf(4);
  EdgeInsets get h8 => hf(8);
  EdgeInsets get h10 => hf(10);
  EdgeInsets get h12 => hf(12);
  EdgeInsets get h15 => hf(15);
  EdgeInsets get h16 => hf(16);
  EdgeInsets get h18 => hf(18);
  EdgeInsets get h20 => hf(20);
  EdgeInsets get h24 => hf(24);
  EdgeInsets get h30 => hf(30);
  EdgeInsets get h32 => hf(32);
  EdgeInsets get h40 => hf(40);

  //============================================================================
  //     **   EdgeInsets From Vertical  **
  //============================================================================
  EdgeInsets vf(double value) => _merge(top: value.h, bottom: value.h);
  EdgeInsets get v2 => vf(2);
  EdgeInsets get v4 => vf(4);
  EdgeInsets get v6 => vf(6);
  EdgeInsets get v8 => vf(8);
  EdgeInsets get v10 => vf(10);
  EdgeInsets get v12 => vf(12);
  EdgeInsets get v15 => vf(15);
  EdgeInsets get v16 => vf(16);
  EdgeInsets get v20 => vf(20);
  EdgeInsets get v24 => vf(24);
  EdgeInsets get v30 => vf(30);
  EdgeInsets get v40 => vf(40);

  //============================================================================
  //     **   EdgeInsets From All  **
  //============================================================================
  EdgeInsets allF(double value) => _merge(
      left: value.w, right: value.w, top: value.h, bottom: value.h);
  EdgeInsets get all4 => allF(4);
  EdgeInsets get all8 => allF(8);
  EdgeInsets get all10 => allF(10);
  EdgeInsets get all12 => allF(12);
  EdgeInsets get all16 => allF(16);
  EdgeInsets get all20 => allF(20);
  EdgeInsets get all24 => allF(24);
  EdgeInsets get all30 => allF(30);
  EdgeInsets get all40 => allF(40);

  //============================================================================
  //     **   Top / Bottom / Left / Right **
  //============================================================================
  EdgeInsets tf(double value) => _merge(top: value.h);
  EdgeInsets bf(double value) => _merge(bottom: value.h);
  EdgeInsets lf(double value) => _merge(left: value.w);
  EdgeInsets rf(double value) => _merge(right: value.w);

  //============================================================================
  //     **   EdgeInsets From Top  **
  //============================================================================

  EdgeInsets get t => tf(5);
  EdgeInsets get t2 => tf(2);
  EdgeInsets get t4 => tf(4);
  EdgeInsets get t6 => tf(6);
  EdgeInsets get t8 => tf(8);
  EdgeInsets get t10 => tf(10);
  EdgeInsets get t12 => tf(12);
  EdgeInsets get t15 => tf(15);
  EdgeInsets get t20 => tf(20);
  EdgeInsets get t24 => tf(24);
  EdgeInsets get t30 => tf(30);
  EdgeInsets get t40 => tf(40);

  //============================================================================
  //     **   EdgeInsets From Bottom  **
  //============================================================================

  EdgeInsets get b => bf(5);
  EdgeInsets get b2 => bf(2);
  EdgeInsets get b4 => bf(4);
  EdgeInsets get b6 => bf(6);
  EdgeInsets get b8 => bf(8);
  EdgeInsets get b10 => bf(10);
  EdgeInsets get b12 => bf(12);
  EdgeInsets get b15 => bf(15);
  EdgeInsets get b20 => bf(20);
  EdgeInsets get b24 => bf(24);
  EdgeInsets get b30 => bf(30);
  EdgeInsets get b40 => bf(40);
  EdgeInsets get b48 => bf(48);

  //============================================================================
  //     **   EdgeInsets From Right  **
  //============================================================================

  EdgeInsets get r => rf(5);
  EdgeInsets get r2 => rf(2);
  EdgeInsets get r4 => rf(4);
  EdgeInsets get r6 => rf(6);
  EdgeInsets get r8 => rf(8);
  EdgeInsets get r10 => rf(10);
  EdgeInsets get r12 => rf(12);
  EdgeInsets get r15 => rf(15);
  EdgeInsets get r16 => rf(16);
  EdgeInsets get r20 => rf(20);
  EdgeInsets get r24 => rf(24);
  EdgeInsets get r30 => rf(30);
  EdgeInsets get r40 => rf(40);

  //============================================================================
  //     **   EdgeInsets From Left  **
  //============================================================================

  EdgeInsets get l => lf(5);
  EdgeInsets get l2 => lf(2);
  EdgeInsets get l4 => lf(4);
  EdgeInsets get l6 => lf(6);
  EdgeInsets get l8 => lf(8);
  EdgeInsets get l10 => lf(10);
  EdgeInsets get l12 => lf(12);
  EdgeInsets get l15 => lf(15);
  EdgeInsets get l16 => lf(16);
  EdgeInsets get l20 => lf(20);
  EdgeInsets get l24 => lf(24);
  EdgeInsets get l30 => lf(30);
  EdgeInsets get l40 => lf(40);
  EdgeInsets get l48 => lf(48);
}
