import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/app/app.dart';
import 'package:vm_ui/core/ui_kit/buttons/buttons.dart';
import 'package:vm_ui/core/ui_kit/containers/footer_content.dart';
import 'package:vm_ui/core/ui_kit/pages/background.dart';
import 'package:vm_ui/core/ui_kit/themes/colors.dart';
import 'package:vm_ui/features/splash/presentation/splash_page.dart';

void main() {
  testWidgets('app opens on the composed splash page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VmUiApp());

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(VMPageBackground), findsOneWidget);
    expect(find.byType(VMFooterContent), findsOneWidget);
    expect(tester.getSize(find.byType(VMFooterContent)).height, 268.8);
    expect(find.byKey(const ValueKey('splash-logo')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('splash-logo'))).dy,
      120,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('splash-logo'))).width,
      closeTo(425, 0.001),
    );
    expect(find.byType(VMButton), findsOneWidget);
    expect(find.text('Sentuh Untuk Memulai Pesanan'), findsOneWidget);
    expect(find.text('Butuh bantuan? Hubungi 0812-1234-5678'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(VMPageBackground),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.begin, Alignment.centerRight);
    expect(gradient.end, Alignment.centerLeft);
    expect(gradient.colors, [VMColorTheme.red80, VMColorTheme.red60]);

    final swirls = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(swirls.fit, BoxFit.cover);
  });

  testWidgets('splash footer fits a compact logical screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VmUiApp());

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(VMFooterContent)).height,
      closeTo(89.6, 0.001),
    );
  });
}
