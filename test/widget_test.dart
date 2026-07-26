import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/app/app.dart';
import 'package:vm_ui/core/ui_kit/colors.dart';
import 'package:vm_ui/core/ui_kit/pages/background.dart';

void main() {
  testWidgets('app displays the page background', (WidgetTester tester) async {
    await tester.pumpWidget(const VmUiApp());

    expect(find.byType(VMPageBackground), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(VMPageBackground),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.begin, Alignment.centerRight);
    expect(gradient.end, Alignment.centerLeft);
    expect(gradient.colors, [VMColorTheme.red80, VMColorTheme.red60]);

    final swirls = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(swirls.fit, BoxFit.cover);
  });
}
