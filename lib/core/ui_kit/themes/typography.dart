import 'package:flutter/material.dart';
import 'package:vm_ui/core/ui_kit/themes/colors.dart';

class VMTextStyles {
  VMTextStyles._();

  static const _baseTextColor = VMColorTheme.black100;
  static const _leadingDistibution = TextLeadingDistribution.even;

  static const TextStyle body = TextStyle(
    color: _baseTextColor,
    leadingDistribution: _leadingDistibution,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}

extension VMTextStyleAdd on TextStyle {
  TextStyle get bold {
    return copyWith(fontWeight: FontWeight.w700);
  }

  TextStyle get xL {
    return copyWith(fontSize: 20);
  }

  TextStyle get button {
    return copyWith(color: VMColorTheme.neutral);
  }
}
