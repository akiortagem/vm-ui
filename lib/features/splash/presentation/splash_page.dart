import 'package:flutter/material.dart';
import 'package:vm_ui/features/menu_selection/presentation/menu_selection_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vm_ui/core/ui_kit/buttons/buttons.dart';
import 'package:vm_ui/core/ui_kit/containers/footer_content.dart';
import 'package:vm_ui/core/ui_kit/pages/background.dart';
import 'package:vm_ui/core/ui_kit/themes/typography.dart';
import 'package:vm_ui/features/splash/presentation/widgets/hero_dishes.dart';

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
          SvgPicture.asset(
            'lib/core/ui_kit/assets/img/circles.svg',
            key: const ValueKey('splash-circles'),
            fit: BoxFit.cover,
          ),
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
          Positioned(
            top: screenSize.height * 0.18,
            bottom: footerHeight,
            left: 0,
            right: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: screenSize.width,
                child: HeroDishes(
                  edgeOverflow: screenSize.width * 0.032,
                  // Test images only. Replace these with the actual dish data.
                  dishes: [
                    Image.asset(
                      'lib/core/ui_kit/assets/test_img/nasi_goreng.png',
                      key: const ValueKey('test-nasi-goreng'),
                      width: screenSize.width * 0.72,
                    ),
                    Image.asset(
                      'lib/core/ui_kit/assets/test_img/mie_goreng.png',
                      key: const ValueKey('test-mie-goreng'),
                      width: screenSize.width * 0.72,
                    ),
                  ],
                ),
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
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const MenuSelectionPage(),
                              ),
                            ),
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
