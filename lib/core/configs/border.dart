import 'package:flutter/material.dart';

extension SuperBorder on Border {
  //----------------------------------------------------------------------------
  // Internal Merge (chainable sides)
  //----------------------------------------------------------------------------
  Border _merge({
    double? left,
    double? right,
    double? top,
    double? bottom,
    Color? color,
  }) {
    BorderSide copy(BorderSide old, double? w) =>
        BorderSide(width: w ?? old.width, color: color ?? old.color);

    return Border(
      left: copy(this.left, left),
      right: copy(this.right, right),
      top: copy(this.top, top),
      bottom: copy(this.bottom, bottom),
    );
  }

  //----------------------------------------------------------------------------
  // Chainable side helpers
  //----------------------------------------------------------------------------
  Border _top(double w, {Color color = Colors.black}) =>
      _merge(top: w, color: color);
  Border _bottom(double w, {Color color = Colors.black}) =>
      _merge(bottom: w, color: color);
  Border _left(double w, {Color color = Colors.black}) =>
      _merge(left: w, color: color);
  Border _right(double w, {Color color = Colors.black}) =>
      _merge(right: w, color: color);

  Border _vertical(double w, {Color color = Colors.black}) =>
      _merge(top: w, bottom: w, color: color);

  Border _horizontal(double w, {Color color = Colors.black}) =>
      _merge(left: w, right: w, color: color);

  //----------------------------------------------------------------------------
  // All Sides
  //----------------------------------------------------------------------------
  Border _all(double w, {Color color = Colors.black}) =>
      Border.all(width: w, color: color);

  Border get all_01 => _all(0.1);
  Border get all_02 => _all(0.2);
  Border get all_03 => _all(0.3);
  Border get all_04 => _all(0.4);
  Border get all_05 => _all(0.5);
  Border get all_06 => _all(0.6);
  Border get all_07 => _all(0.7);
  Border get all_08 => _all(0.8);
  Border get all_09 => _all(0.9);

  Border get all => _all(1);
  Border get all2 => _all(2);
  Border get all3 => _all(3);
  Border get all4 => _all(4);
  Border get all5 => _all(5);
  Border get all6 => _all(6);
  Border get all7 => _all(7);
  Border get all8 => _all(8);
  Border get all9 => _all(9);
  Border get all10 => _all(10);

  //----------------------------------------------------------------------------
  // Top
  //----------------------------------------------------------------------------
  Border get top01 => _top(0.1);
  Border get top02 => _top(0.2);
  Border get top03 => _top(0.3);
  Border get top04 => _top(0.4);
  Border get top05 => _top(0.5);
  Border get top06 => _top(0.6);
  Border get top07 => _top(0.7);
  Border get top08 => _top(0.8);
  Border get top09 => _top(0.9);
  Border get top => _top(1);
  Border get top2 => _top(2);
  Border get top3 => _top(3);
  Border get top4 => _top(4);
  Border get top5 => _top(5);
  Border get top6 => _top(6);
  Border get top7 => _top(7);
  Border get top8 => _top(8);
  Border get top9 => _top(9);
  Border get top10 => _top(10);

  //----------------------------------------------------------------------------
  // Bottom
  //----------------------------------------------------------------------------
  Border get bottom01 => _bottom(0.1);
  Border get bottom02 => _bottom(0.2);
  Border get bottom03 => _bottom(0.3);
  Border get bottom04 => _bottom(0.4);
  Border get bottom05 => _bottom(0.5);
  Border get bottom06 => _bottom(0.6);
  Border get bottom07 => _bottom(0.7);
  Border get bottom08 => _bottom(0.8);
  Border get bottom09 => _bottom(0.9);
  Border get bottom => _bottom(1);
  Border get bottom2 => _bottom(2);
  Border get bottom3 => _bottom(3);
  Border get bottom4 => _bottom(4);
  Border get bottom5 => _bottom(5);
  Border get bottom6 => _bottom(6);
  Border get bottom7 => _bottom(7);
  Border get bottom8 => _bottom(8);
  Border get bottom9 => _bottom(9);
  Border get bottom10 => _bottom(10);

  //----------------------------------------------------------------------------
  // Left
  //----------------------------------------------------------------------------
  Border get left01 => _left(0.1);
  Border get left02 => _left(0.2);
  Border get left03 => _left(0.3);
  Border get left04 => _left(0.4);
  Border get left05 => _left(0.5);
  Border get left06 => _left(0.6);
  Border get left07 => _left(0.7);
  Border get left08 => _left(0.8);
  Border get left09 => _left(0.9);
  Border get left => _left(1);
  Border get left2 => _left(2);
  Border get left3 => _left(3);
  Border get left4 => _left(4);
  Border get left5 => _left(5);
  Border get left6 => _left(6);
  Border get left7 => _left(7);
  Border get left8 => _left(8);
  Border get left9 => _left(9);
  Border get left10 => _left(10);

  //----------------------------------------------------------------------------
  // Right
  //----------------------------------------------------------------------------
  Border get right01 => _right(0.1);
  Border get right02 => _right(0.2);
  Border get right03 => _right(0.3);
  Border get right04 => _right(0.4);
  Border get right05 => _right(0.5);
  Border get right06 => _right(0.6);
  Border get right07 => _right(0.7);
  Border get right08 => _right(0.8);
  Border get right09 => _right(0.9);
  Border get right => _right(1);
  Border get right2 => _right(2);
  Border get right3 => _right(3);
  Border get right4 => _right(4);
  Border get right5 => _right(5);
  Border get right6 => _right(6);
  Border get right7 => _right(7);
  Border get right8 => _right(8);
  Border get right9 => _right(9);
  Border get right10 => _right(10);

  //----------------------------------------------------------------------------
  // Vertical
  //----------------------------------------------------------------------------
  Border get vertical01 => _vertical(0.1);
  Border get vertical05 => _vertical(0.5);
  Border get vertical => _vertical(1);
  Border get vertical2 => _vertical(2);
  Border get vertical3 => _vertical(3);
  Border get vertical4 => _vertical(4);
  Border get vertical5 => _vertical(5);
  Border get vertical6 => _vertical(6);
  Border get vertical7 => _vertical(7);
  Border get vertical8 => _vertical(8);
  Border get vertical9 => _vertical(9);
  Border get vertical10 => _vertical(10);

  //----------------------------------------------------------------------------
  // Horizontal
  //----------------------------------------------------------------------------
  Border get horizontal01 => _horizontal(0.1);
  Border get horizontal05 => _horizontal(0.5);
  Border get horizontal => _horizontal(1);
  Border get horizontal2 => _horizontal(2);
  Border get horizontal3 => _horizontal(3);
  Border get horizontal4 => _horizontal(4);
  Border get horizontal5 => _horizontal(5);
  Border get horizontal6 => _horizontal(6);
  Border get horizontal7 => _horizontal(7);
  Border get horizontal8 => _horizontal(8);
  Border get horizontal9 => _horizontal(9);
  Border get horizontal10 => _horizontal(10);
}
