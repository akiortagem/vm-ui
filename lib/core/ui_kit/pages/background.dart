import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vm_ui/core/ui_kit/themes/colors.dart';

class VMPageBackground extends StatelessWidget {
  const VMPageBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [VMColorTheme.red80, VMColorTheme.red60],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            'lib/core/ui_kit/assets/img/swirls.svg',
            fit: BoxFit.cover,
          ),
          if (child case final child?) child,
        ],
      ),
    );
  }
}
