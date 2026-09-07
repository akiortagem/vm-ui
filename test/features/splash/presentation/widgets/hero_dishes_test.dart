import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/features/splash/presentation/widgets/hero_dishes.dart';

void main() {
  testWidgets('lays dishes out vertically with alternating alignment', (
    tester,
  ) async {
    final dishes = List.generate(
      4,
      (index) => Image(
        key: ValueKey('dish-$index'),
        image: MemoryImage(Uint8List.fromList(_transparentImage)),
        width: 40,
        height: 40,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          key: const ValueKey('hero-bounds'),
          width: 200,
          child: HeroDishes(dishes: dishes, randomRotation: false),
        ),
      ),
    );

    final bounds = tester.getRect(find.byKey(const ValueKey('hero-bounds')));

    expect(
      tester.getTopRight(find.byKey(const ValueKey('dish-0'))).dx,
      bounds.right,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('dish-1'))).dx,
      bounds.left,
    );
    expect(
      tester.getTopRight(find.byKey(const ValueKey('dish-2'))).dx,
      bounds.right,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('dish-3'))).dx,
      bounds.left,
    );

    for (var index = 1; index < dishes.length; index++) {
      expect(
        tester.getTopLeft(find.byKey(ValueKey('dish-$index'))).dy,
        greaterThan(
          tester.getTopLeft(find.byKey(ValueKey('dish-${index - 1}'))).dy,
        ),
      );
    }
  });

  testWidgets('supports an empty dish list', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: HeroDishes(dishes: []),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNothing);
  });
}

const _transparentImage = <int>[
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1f,
  0x15,
  0xc4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x44,
  0x41,
  0x54,
  0x08,
  0xd7,
  0x63,
  0xf8,
  0xcf,
  0xc0,
  0xf0,
  0x1f,
  0x00,
  0x05,
  0x00,
  0x01,
  0xff,
  0x89,
  0x99,
  0x3d,
  0x1d,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4e,
  0x44,
  0xae,
  0x42,
  0x60,
  0x82,
];
