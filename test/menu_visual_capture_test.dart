import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/app/theme/app_theme.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_dish.dart';
import 'package:vm_ui/features/menu_selection/presentation/menu_selection_page.dart';

void main() {
  testWidgets('capture menu states', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    final loader = FontLoader('Figtree')..addFont(rootBundle.load('lib/core/ui_kit/assets/fonts/Figtree-Variable.ttf'));
    await loader.load();
    for (final limit in [1, 3]) {
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: RepaintBoundary(
        key: key, child: MenuSelectionPage(maxSelectedItems: limit),
      )));
      await tester.runAsync(() async {
        for (final dish in menuDishes) {
          await precacheImage(AssetImage(dish.imageAsset), key.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      for (var i = 0; i < limit; i++) {
        await tester.tap(find.text('Pesan').first);
        await tester.pumpAndSettle();
      }
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
      final capture = await boundary.toImage(pixelRatio: 0.5);
      final bytes = await capture.toByteData(format: ui.ImageByteFormat.png);
      await File('/tmp/menu-selected-$limit.png').writeAsBytes(bytes!.buffer.asUint8List());
      capture.dispose();
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
