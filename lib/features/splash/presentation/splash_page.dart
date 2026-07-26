import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vm_ui/core/ui_kit/buttons/buttons.dart';
import 'package:vm_ui/core/ui_kit/containers/footer_content.dart';
import 'package:vm_ui/core/ui_kit/pages/background.dart';
import 'package:vm_ui/core/ui_kit/themes/typography.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final footerHeight = screenSize.height * 0.14;
    final verticalPadding = ((64 / 1920)) * screenSize.height;
    final horizontalPadding = (screenSize.width * (80 / 1080)).clamp(
      24.0,
      80.0,
    );

    return VMPageBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: screenSize.height * 0.0625,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'lib/core/ui_kit/assets/img/LOGO.svg',
                key: const ValueKey('splash-logo'),
                width: screenSize.width * (425 / 1080),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: VMFooterContent(
              height: footerHeight,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VMButton(
                            label: 'Sentuh Untuk Memulai Pesanan',
                            onPressed: () {},
                            size: VMButtonSize.large,
                            expand: true,
                          ),
                          const SizedBox(height: 44),
                          Text(
                            'Butuh bantuan? Hubungi 0812-1234-5678',
                            textAlign: TextAlign.center,
                            style: VMTextStyles.body.bold.xL,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
