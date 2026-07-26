import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    fontFamily: 'Figtree',
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  );
}
