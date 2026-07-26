import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/core/ui_kit/containers/footer_content.dart';

void main() {
  testWidgets('renders a full-width rounded footer with composable content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: VMFooterContent(child: Text('Footer content')),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(VMFooterContent),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(container.constraints!.maxWidth, double.infinity);
    expect(
      container.padding,
      const EdgeInsets.symmetric(horizontal: 80, vertical: 64),
    );
    expect(decoration.color, Colors.white);
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(52)),
    );
    expect(find.text('Footer content'), findsOneWidget);
  });

  testWidgets('can extend to a custom height from the bottom', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: VMFooterContent(height: 320, child: Text('Footer content')),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(VMFooterContent)).height, 320);
    expect(tester.getBottomLeft(find.byType(VMFooterContent)).dy, 600);
  });
}
