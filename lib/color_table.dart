import 'package:flutter/material.dart';

// 色管理
class ColorTable {
  static const int _primaryRedValue = 0xFFDB5E4B;
  static const MaterialColor primaryRedColor = MaterialColor(
    _primaryRedValue,
    <int, Color>{
      500: Color(_primaryRedValue),
    },
  );

  static const int _primaryBlueValue = 0xFF398FD8;
  static const MaterialColor primaryBlueColor = MaterialColor(
    _primaryBlueValue,
    <int, Color>{
      500: Color(_primaryBlueValue),
    },
  );

  static const int _primaryGreenValue = 0xFF77BA76;
  static const MaterialColor primaryGreenColor = MaterialColor(
    _primaryGreenValue,
    <int, Color>{
      500: Color(_primaryGreenValue),
    },
  );

  static const int _primaryWhiteValue = 0xFFFAFEFF;
  static const MaterialColor primaryWhiteColor = MaterialColor(
    _primaryWhiteValue,
    <int, Color>{
      500: Color(_primaryWhiteValue),
    },
  );

  static const int _primaryNavyValue = 0xFF071E90;
  static const MaterialColor primaryNavyColor = MaterialColor(
    _primaryNavyValue,
    <int, Color>{
      500: Color(_primaryNavyValue),
    },
  );

  static const int _primaryBlackValue = 0xFF151515;
  static const MaterialColor primaryBlackColor = MaterialColor(
    _primaryBlackValue,
    <int, Color>{
      500: Color(_primaryBlackValue),
    },
  );
}
