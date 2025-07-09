import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SuperRadius on BorderRadius {
  // Merge current + new corner radius (instead of overriding)
  BorderRadius _merge({
    Radius? topLeft,
    Radius? topRight,
    Radius? bottomLeft,
    Radius? bottomRight,
  }) {
    return BorderRadius.only(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
    );
  }

  // Radius from all corners
  BorderRadius _allF(double value) {
    var r = Radius.circular(value.r);
    return BorderRadius.all(r);
  }

  // Radius from each side
  BorderRadius _tlF(double value) => _merge(topLeft: Radius.circular(value.r));
  BorderRadius _trF(double value) => _merge(topRight: Radius.circular(value.r));
  BorderRadius _blF(double value) =>
      _merge(bottomLeft: Radius.circular(value.r));
  BorderRadius _brF(double value) =>
      _merge(bottomRight: Radius.circular(value.r));

  BorderRadius _tF(double value) => _merge(
    topLeft: Radius.circular(value.r),
    topRight: Radius.circular(value.r),
  );

  BorderRadius _bF(double value) => _merge(
    bottomLeft: Radius.circular(value.r),
    bottomRight: Radius.circular(value.r),
  );

  BorderRadius _lF(double value) => _merge(
    topLeft: Radius.circular(value.r),
    bottomLeft: Radius.circular(value.r),
  );

  BorderRadius _rF(double value) => _merge(
    topRight: Radius.circular(value.r),
    bottomRight: Radius.circular(value.r),
  );

  // Sample fixed values
    // tl
  BorderRadius get tl2 => _tlF(2);
  BorderRadius get tl4 => _tlF(4);
  BorderRadius get tl5 => _tlF(5);
  BorderRadius get tl6 => _tlF(6);
  BorderRadius get tl8 => _tlF(8);
  BorderRadius get tl12 => _tlF(12);
  BorderRadius get tl14 => _tlF(14);
  BorderRadius get tl16 => _tlF(16);
  BorderRadius get tl18 => _tlF(18);
  BorderRadius get tl24 => _tlF(24);
  BorderRadius get tl30 => _tlF(30);
  BorderRadius get tl40 => _tlF(40);
  BorderRadius get tl50 => _tlF(50);
  BorderRadius get tl100 => _tlF(100);
    // tr
  BorderRadius get tr2 => _trF(2);
  BorderRadius get tr4 => _trF(4);
  BorderRadius get tr5 => _trF(5);
  BorderRadius get tr6 => _trF(6);
  BorderRadius get tr8 => _trF(8);
  BorderRadius get tr12 => _trF(12);
  BorderRadius get tr14 => _trF(14);
  BorderRadius get tr16 => _trF(16);
  BorderRadius get tr18 => _trF(18);
  BorderRadius get tr24 => _trF(24);
  BorderRadius get tr30 => _trF(30);
  BorderRadius get tr40 => _trF(40);
  BorderRadius get tr50 => _trF(50);
  BorderRadius get tr100 => _trF(100);
    // bl
  BorderRadius get bl2 => _blF(2);
  BorderRadius get bl4 => _blF(4);
  BorderRadius get bl5 => _blF(5);
  BorderRadius get bl6 => _blF(6);
  BorderRadius get bl8 => _blF(8);
  BorderRadius get bl12 => _blF(12);
  BorderRadius get bl14 => _blF(14);
  BorderRadius get bl16 => _blF(16);
  BorderRadius get bl18 => _blF(18);
  BorderRadius get bl24 => _blF(24);
  BorderRadius get bl30 => _blF(30);
  BorderRadius get bl40 => _blF(40);
  BorderRadius get bl50 => _blF(50);
  BorderRadius get bl100 => _blF(100);
    // br
  BorderRadius get br2 => _brF(2);
  BorderRadius get br4 => _brF(4);
  BorderRadius get br5 => _brF(5);
  BorderRadius get br6 => _brF(6);
  BorderRadius get br8 => _brF(8);
  BorderRadius get br12 => _brF(12);
  BorderRadius get br14 => _brF(14);
  BorderRadius get br16 => _brF(16);
  BorderRadius get br18 => _brF(18);
  BorderRadius get br24 => _brF(24);
  BorderRadius get br30 => _brF(30);
  BorderRadius get br40 => _brF(40);
  BorderRadius get br50 => _brF(50);
  BorderRadius get br100 => _brF(100);

  // top
  BorderRadius get top2 => _tF(2);
  BorderRadius get top4 => _tF(4);
  BorderRadius get top5 => _tF(5);
  BorderRadius get top6 => _tF(6);
  BorderRadius get top8 => _tF(8);
  BorderRadius get top12 => _tF(12);
  BorderRadius get top14 => _tF(14);
  BorderRadius get top16 => _tF(16);
  BorderRadius get top18 => _tF(18);
  BorderRadius get top24 => _tF(24);
  BorderRadius get top30 => _tF(30);
  BorderRadius get top40 => _tF(40);
  BorderRadius get top50 => _tF(50);
  BorderRadius get top100 => _tF(100);
    // bottom
  BorderRadius get bottom2 => _bF(2);
  BorderRadius get bottom4 => _bF(4);
  BorderRadius get bottom5 => _bF(5);
  BorderRadius get bottom6 => _bF(6);
  BorderRadius get bottom8 => _bF(8);
  BorderRadius get bottom12 => _bF(12);
  BorderRadius get bottom14 => _bF(14);
  BorderRadius get bottom16 => _bF(16);
  BorderRadius get bottom18 => _bF(18);
  BorderRadius get bottom24 => _bF(24);
  BorderRadius get bottom30 => _bF(30);
  BorderRadius get bottom40 => _bF(40);
  BorderRadius get bottom50 => _bF(50);
  BorderRadius get bottom100 => _bF(100);
    // left
  BorderRadius get left2 => _lF(2);
  BorderRadius get left4 => _lF(4);
  BorderRadius get left5 => _lF(5);
  BorderRadius get left6 => _lF(6);
  BorderRadius get left8 => _lF(8);
  BorderRadius get left12 => _lF(12);
  BorderRadius get left14 => _lF(14);
  BorderRadius get left16 => _lF(16);
  BorderRadius get left18 => _lF(18);
  BorderRadius get left24 => _lF(24);
  BorderRadius get left30 => _lF(30);
  BorderRadius get left40 => _lF(40);
  BorderRadius get left50 => _lF(50);
  BorderRadius get left100 => _lF(100);
    // right
  BorderRadius get right2 => _rF(2);
  BorderRadius get right4 => _rF(4);
  BorderRadius get right5 => _rF(5);
  BorderRadius get right6 => _rF(6);
  BorderRadius get right8 => _rF(8);
  BorderRadius get right12 => _rF(12);
  BorderRadius get right14 => _rF(14);
  BorderRadius get right16 => _rF(16);
  BorderRadius get right18 => _rF(18);
  BorderRadius get right24 => _rF(24);
  BorderRadius get right30 => _rF(30);
  BorderRadius get right40 => _rF(40);
  BorderRadius get right50 => _rF(50);
  BorderRadius get right100 => _rF(100);

  // all
  BorderRadius get all2 => _allF(2);
  BorderRadius get all4 => _allF(4);
  BorderRadius get all5 => _allF(5);
  BorderRadius get all6 => _allF(6);
  BorderRadius get all8 => _allF(8);
  BorderRadius get all12 => _allF(12);
  BorderRadius get all14 => _allF(14);
  BorderRadius get all16 => _allF(16);
  BorderRadius get all18 => _allF(18);
  BorderRadius get all24 => _allF(24);
  BorderRadius get all30 => _allF(30);
  BorderRadius get all40 => _allF(40);
  BorderRadius get all50 => _allF(50);
  BorderRadius get all100 => _allF(100);
}
