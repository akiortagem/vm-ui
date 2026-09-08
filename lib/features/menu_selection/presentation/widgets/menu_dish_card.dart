import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vm_ui/core/ui_kit/themes/colors.dart';
import 'package:vm_ui/core/ui_kit/themes/typography.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_dish.dart';

class MenuDishCard extends StatelessWidget {
  const MenuDishCard({
    required this.dish,
    required this.onOrder,
    this.selected = false,
    this.quantity = 1,
    super.key,
  });
  final MenuDish dish;
  final VoidCallback? onOrder;
  final bool selected;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final titleStyle = VMTextStyles.body.bold.copyWith(
      fontSize: 24,
      height: 32 / 24,
    );
    return Container(
      height: 408,
      decoration: BoxDecoration(
        color: VMColorTheme.neutral,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(4, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Row(
              children: [
                Image.asset(
                  dish.imageAsset,
                  width: 360,
                  height: 360,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dish.name, style: titleStyle),
                      const SizedBox(height: 12),
                      Text(
                        dish.description,
                        style: VMTextStyles.body.xL.copyWith(
                          color: VMColorTheme.black70,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(formatRupiah(dish.price), style: titleStyle),
                      const SizedBox(height: 24),
                      if (selected)
                        Container(
                          width: 306,
                          height: 56,
                          decoration: BoxDecoration(
                            color: VMColorTheme.neutral,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: VMColorTheme.black30),
                          ),
                          // Keep the icon slots 8 px from the outer edge.
                          padding: const EdgeInsets.all(7),
                          child: Row(
                            children: [
                              _QuantityIcon(
                                asset: 'minus.svg',
                                label: 'Hapus ${dish.name}',
                                onPressed: onOrder,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$quantity',
                                  textAlign: TextAlign.center,
                                  semanticsLabel:
                                      'Jumlah ${dish.name}: $quantity',
                                  style: titleStyle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              _QuantityIcon(
                                asset: 'plus_disabled.svg',
                                label: 'Tambah ${dish.name}',
                                onPressed: null,
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: 306,
                          height: 56,
                          child: Semantics(
                            button: true,
                            enabled: onOrder != null,
                            child: Material(
                              borderRadius: BorderRadius.circular(100),
                              clipBehavior: Clip.antiAlias,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: onOrder == null
                                      ? VMColorTheme.black40
                                      : null,
                                  gradient: onOrder == null
                                      ? null
                                      : const LinearGradient(
                                          begin: Alignment(-1, -0.4),
                                          end: Alignment(1, 0.4),
                                          colors: [
                                            VMColorTheme.red60,
                                            VMColorTheme.red80,
                                          ],
                                        ),
                                ),
                                child: InkWell(
                                  onTap: onOrder,
                                  child: Center(
                                    child: Text(
                                      'Pesan',
                                      semanticsLabel: 'Pesan ${dish.name}',
                                      style: titleStyle.copyWith(
                                        color: VMColorTheme.neutral,
                                        height: 28 / 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (dish.isBestSeller)
            Positioned(
              left: 0,
              top: 24,
              child: Container(
                width: 121,
                height: 34,
                padding: const EdgeInsets.only(left: 16),
                decoration: const BoxDecoration(
                  color: VMColorTheme.red60,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0.9408,
                          vertical: 1.2384,
                        ),
                        child: SvgPicture.asset(
                          'lib/core/ui_kit/assets/menu/best_seller.svg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Best Seller',
                      style: VMTextStyles.body.bold.copyWith(
                        fontSize: 14,
                        height: 18 / 14,
                        color: VMColorTheme.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Figma's 40 px icon slot contains a 33⅓ px exported glyph.
class _QuantityIcon extends StatelessWidget {
  const _QuantityIcon({
    required this.asset,
    required this.label,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        padding: const EdgeInsets.all(40 / 12),
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: SvgPicture.asset(
          'lib/core/ui_kit/assets/menu/$asset',
          width: 40 * 5 / 6,
          height: 40 * 5 / 6,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
