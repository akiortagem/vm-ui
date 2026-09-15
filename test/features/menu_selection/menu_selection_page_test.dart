import '../../menu_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/app/app.dart';
import 'package:vm_ui/app/theme/app_theme.dart';
import 'package:vm_ui/core/ui_kit/buttons/buttons.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_dish.dart';
import 'package:vm_ui/features/menu_selection/presentation/menu_selection_page.dart';
import 'package:vm_ui/features/menu_selection/presentation/widgets/menu_dish_card.dart';
import 'package:vm_ui/features/splash/presentation/splash_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Figtree')
      ..addFont(
        rootBundle.load('lib/core/ui_kit/assets/fonts/Figtree-Variable.ttf'),
      );
    await loader.load();
  });
  for (final size in [const Size(1080, 1920), const Size(540, 960)]) {
    testWidgets('start opens menu at $size and selection updates total', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(VmUiApp(loadMenu: fixtureLoadMenu));
      await tester.tap(find.text('Sentuh Untuk Memulai Pesanan'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuDishCard), findsNWidgets(3));
      expect(find.text('Best Seller'), findsOneWidget);
      expect(find.text('Rp 0'), findsOneWidget);
      expect(
        MediaQuery.sizeOf(tester.element(find.byType(MenuSelectionPage))),
        VmUiApp.designSize,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Pesan').at(0));
      await tester.tap(find.text('Pesan').at(1));
      await tester.pump();
      expect(find.text('Rp 20.000'), findsNWidgets(2));
      expect(tester.widget<VMButton>(find.byType(VMButton)).onPressed, isNull);
      Navigator.of(tester.element(find.byType(MenuSelectionPage))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SplashPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('checkout receives selected dishes only after an order', (
    tester,
  ) async {
    tester.view.physicalSize = VmUiApp.designSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    List<MenuDish>? checkout;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MenuSelectionPage(
          loadMenu: fixtureLoadMenu,
          onCheckout: (order) => checkout = order,
        ),
      ),
    );
    expect(tester.widget<VMButton>(find.byType(VMButton)).onPressed, isNull);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesan').at(2));
    await tester.pump();
    expect(find.text('Rp 22.000'), findsNWidgets(2));
    await tester.tap(find.text('Bayar Sekarang'));
    expect(checkout, [menuDishes[2]]);
    final plus = find.byTooltip('Tambah Nasi Goreng Hongkong');
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(of: plus, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(plus);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesan').first);
    await tester.pump();
    await tester.tap(find.text('Bayar Sekarang'));
    expect(checkout, [menuDishes[2]]);
    await tester.tap(find.byTooltip('Hapus Nasi Goreng Hongkong'));
    await tester.pump();
    expect(find.text('Rp 0'), findsOneWidget);
    expect(tester.widget<VMButton>(find.byType(VMButton)).onPressed, isNull);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesan').first);
    await tester.pump();
    await tester.tap(find.text('Bayar Sekarang'));
    expect(checkout, [menuDishes[0]]);
    expect(tester.takeException(), isNull);
  });
  testWidgets('configured limits and fixed quantities apply to checkout', (
    tester,
  ) async {
    tester.view.physicalSize = VmUiApp.designSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    List<MenuDish>? checkout;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MenuSelectionPage(
          loadMenu: fixtureLoadMenu,
          maxSelectedItems: 2,
          quantityPerItem: 3,
          onCheckout: (order) => checkout = order,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesan').first);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesan').first);
    await tester.pump();
    await tester.tap(find.text('Pesan'));
    await tester.pump();
    expect(find.text('Rp 144.000'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));
    await tester.tap(find.text('Bayar Sekarang'));
    expect(checkout, [
      menuDishes[0],
      menuDishes[0],
      menuDishes[0],
      menuDishes[1],
      menuDishes[1],
      menuDishes[1],
    ]);
    expect(tester.takeException(), isNull);
  });
}
