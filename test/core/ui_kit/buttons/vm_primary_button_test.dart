import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/core/ui_kit/buttons/buttons.dart';
import 'package:vm_ui/core/ui_kit/colors.dart';

void main() {
  Widget buildButton(VMButton button) {
    return MaterialApp(
      home: Scaffold(body: Center(child: button)),
    );
  }

  ButtonStyle styleOf(WidgetTester tester) {
    return tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style!;
  }

  testWidgets('uses the correct dimensions for every size', (tester) async {
    const expectedSizes = {
      VMButtonSize.large: Size(254, 72),
      VMButtonSize.medium: Size(140, 40),
      VMButtonSize.small: Size(98, 28),
    };

    for (final entry in expectedSizes.entries) {
      await tester.pumpWidget(
        buildButton(
          VMButton(label: 'Primary Active', onPressed: () {}, size: entry.key),
        ),
      );

      expect(tester.getSize(find.byType(ElevatedButton)), entry.value);
    }
  });

  testWidgets('filled button resolves active, pressed and disabled colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildButton(VMButton(label: 'Primary Active', onPressed: () {})),
    );

    var style = styleOf(tester);
    expect(style.backgroundColor!.resolve({}), VMColorTheme.red60);
    expect(
      style.backgroundColor!.resolve({WidgetState.pressed}),
      VMColorTheme.red80,
    );

    await tester.pumpWidget(
      buildButton(const VMButton(label: 'Primary Disabled', onPressed: null)),
    );
    style = styleOf(tester);
    expect(
      style.backgroundColor!.resolve({WidgetState.disabled}),
      VMColorTheme.black40,
    );
  });

  testWidgets('outlined button is transparent and changes border by state', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildButton(VMButton.outlined(label: 'Primary Active', onPressed: () {})),
    );

    final style = styleOf(tester);
    expect(style.backgroundColor!.resolve({}), Colors.transparent);
    expect(style.side!.resolve({})!.color, VMColorTheme.red60);
    expect(
      style.side!.resolve({WidgetState.pressed})!.color,
      VMColorTheme.red70,
    );
    expect(
      style.side!.resolve({WidgetState.disabled})!.color,
      VMColorTheme.black40,
    );
  });

  testWidgets('expand fills the available width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: VMButton(
              label: 'Primary Active',
              onPressed: () {},
              expand: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ElevatedButton)).width, 320);
  });
}
