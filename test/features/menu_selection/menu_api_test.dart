import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vm_ui/app/app.dart';
import 'package:vm_ui/core/network/api_client.dart';
import 'package:vm_ui/core/ui_kit/containers/footer_content.dart';
import 'package:vm_ui/features/menu_selection/data/api_menu_repository.dart';
import 'package:vm_ui/features/menu_selection/domain/load_menu.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_dish.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_repository.dart';
import 'package:vm_ui/features/menu_selection/presentation/menu_selection_page.dart';

class _Store implements CredentialStore {
  @override
  Future<MachineCredentials?> read() async => MachineCredentials(
    machineId: 7,
    token: 'test-token',
    refreshToken: 'test-refresh',
  );
  @override
  Future<void> write(MachineCredentials credentials) async {}
  @override
  Future<void> clear() async {}
}

class _Repository implements MenuRepository {
  _Repository(this.load);
  final Future<List<MenuDish>> Function() load;
  @override
  Future<List<MenuDish>> loadMenu() => load();
}

void main() {
  test(
    'loads machine prices and identifiers with omitted optional fields',
    () async {
      final api = await ApiClient.create(
        baseUrl: 'https://cms.example/api',
        credentialStore: _Store(),
        client: MockClient((request) async {
          expect(request.url.path, '/api/vending-machines/7/products');
          expect(request.headers['authorization'], 'Bearer test-token');
          return http.Response(
            jsonEncode({
              'vending_machine_id': 7,
              'products': [
                {
                  'id': 2,
                  'vending_machine_product_id': 12,
                  'name': 'Menu API',
                  'price': 31000,
                  'stock_quantity': 0,
                  'image_url': '/uploads/dish.png',
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);
      final dish = (await ApiMenuRepository(() async => api).loadMenu()).single;
      expect(dish.name, 'Menu API');
      expect(dish.price, 31000);
      expect(dish.id, 2);
      expect(dish.vendingMachineProductId, 12);
      expect(dish.stockQuantity, 0);
      expect(dish.imageUrl, 'https://cms.example/uploads/dish.png');
      expect(dish.description, isNull);
      expect(dish.isBestSeller, isNull);
    },
  );

  void canvas(WidgetTester tester) {
    tester.view.physicalSize = VmUiApp.designSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets(
      'refetches on reopening and scrolls with $kind without moving footer',
      (tester) async {
        canvas(tester);
        var calls = 0;
        final load = LoadMenu(
          _Repository(() async {
            calls++;
            return List.generate(
              6,
              (i) => MenuDish(name: 'Dish $i', price: 1000),
            );
          }),
        );
        await tester.pumpWidget(VmUiApp(loadMenu: load));
        await tester.tap(find.text('Sentuh Untuk Memulai Pesanan'));
        await tester.pumpAndSettle();
        expect(calls, 1);
        final footer = tester.getTopLeft(find.byType(VMFooterContent));
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -1600),
          kind: kind,
        );
        await tester.pumpAndSettle();
        expect(find.text('Dish 5').hitTestable(), findsOneWidget);
        expect(tester.getTopLeft(find.byType(VMFooterContent)), footer);
        Navigator.of(tester.element(find.byType(MenuSelectionPage))).pop();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sentuh Untuk Memulai Pesanan'));
        await tester.pumpAndSettle();
        expect(calls, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'stock limits selection and quantity changes clear invalid orders',
    (tester) async {
      canvas(tester);
      final load = LoadMenu(
        _Repository(
          () async => [
            const MenuDish(name: 'Sold out', price: 1000, stockQuantity: 0),
            const MenuDish(name: 'Low stock', price: 2000, stockQuantity: 1),
            const MenuDish(name: 'Available', price: 3000, stockQuantity: 2),
          ],
        ),
      );
      List<MenuDish>? checkout;
      Widget page(int quantity) => MaterialApp(
        home: MenuSelectionPage(
          loadMenu: load,
          quantityPerItem: quantity,
          onCheckout: (items) => checkout = items,
        ),
      );
      await tester.pumpWidget(page(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pesan').at(0));
      await tester.tap(find.text('Pesan').at(1));
      await tester.pump();
      expect(find.text('Rp 0'), findsOneWidget);
      await tester.tap(find.text('Pesan').at(2));
      await tester.pump();
      expect(find.text('Rp 6.000'), findsOneWidget);
      await tester.tap(find.text('Bayar Sekarang'));
      expect(checkout!.map((dish) => dish.name), ['Available', 'Available']);
      await tester.tap(find.byTooltip('Hapus Available'));
      await tester.pump();
      expect(find.text('Rp 0'), findsOneWidget);
      await tester.tap(find.text('Pesan').at(2));
      await tester.pump();
      await tester.pumpWidget(page(3));
      expect(find.text('Rp 0'), findsOneWidget);
      expect(find.byTooltip('Hapus Available'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('loading failure displays technician screen', (tester) async {
    canvas(tester);
    final pending = Completer<List<MenuDish>>();
    await tester.pumpWidget(
      MaterialApp(
        home: MenuSelectionPage(
          loadMenu: LoadMenu(_Repository(() => pending.future)),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(Exception('network failure'));
    await tester.pumpAndSettle();
    expect(
      find.text('Terjadi gangguan. Teknisi telah dikirim.'),
      findsOneWidget,
    );
    expect(find.text('Bayar Sekarang'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty menu renders safely', (tester) async {
    canvas(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: MenuSelectionPage(
          loadMenu: LoadMenu(_Repository(() async => [])),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Menu belum tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completion after leaving menu is safe', (tester) async {
    canvas(tester);
    final pending = Completer<List<MenuDish>>();
    await tester.pumpWidget(
      MaterialApp(
        home: MenuSelectionPage(
          loadMenu: LoadMenu(_Repository(() => pending.future)),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    pending.complete([]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
