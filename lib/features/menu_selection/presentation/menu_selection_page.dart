import 'package:vm_ui/features/menu_selection/domain/load_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vm_ui/core/ui_kit/buttons/buttons.dart';
import 'package:vm_ui/core/ui_kit/containers/footer_content.dart';
import 'package:vm_ui/core/ui_kit/themes/colors.dart';
import 'package:vm_ui/core/ui_kit/themes/typography.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_dish.dart';
import 'package:vm_ui/features/menu_selection/presentation/widgets/menu_dish_card.dart';

class MenuSelectionPage extends StatefulWidget {
  const MenuSelectionPage({
    required this.loadMenu,
    this.onCheckout,
    this.maxSelectedItems = 1,
    this.quantityPerItem = 1,
    super.key,
  }) : assert(maxSelectedItems > 0),
       assert(quantityPerItem > 0);

  final LoadMenu loadMenu;

  /// Maximum number of distinct dishes selected at once.
  final int maxSelectedItems;

  /// Fixed number of servings for each selected dish.
  final int quantityPerItem;

  /// Connect the payment flow here. Payment stays disabled until connected.
  final ValueChanged<List<MenuDish>>? onCheckout;
  @override
  State<MenuSelectionPage> createState() => _MenuSelectionPageState();
}

class _MenuSelectionPageState extends State<MenuSelectionPage> {
  final List<MenuDish> _order = [];
  List<MenuDish> _dishes = [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dishes = await widget.loadMenu();
      if (!mounted) return;
      setState(() {
        _dishes = dishes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant MenuSelectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_order.length > widget.maxSelectedItems) {
      _order.removeRange(widget.maxSelectedItems, _order.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(80),
            child: Text(
              'Terjadi gangguan. Teknisi telah dikirim.',
              textAlign: TextAlign.center,
              style: VMTextStyles.body.bold.copyWith(fontSize: 40),
            ),
          ),
        ),
      );
    }
    final total = _order.fold(
      0,
      (sum, dish) => sum + dish.price * widget.quantityPerItem,
    );
    final totalStyle = VMTextStyles.body.bold.copyWith(
      fontSize: 32,
      height: 40 / 32,
    );
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.8, -0.277),
            end: Alignment(0.8, 0.277),
            colors: [VMColorTheme.red60, VMColorTheme.red80],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -449.04,
              top: -141.64,
              width: 1817.04,
              height: 2240.289,
              child: SvgPicture.asset(
                'lib/core/ui_kit/assets/menu/swirls.svg',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Text(
                'Halo! Mau pesan apa?',
                textAlign: TextAlign.center,
                style: VMTextStyles.body.bold.copyWith(
                  fontSize: 48,
                  height: 64 / 48,
                  color: VMColorTheme.neutral,
                ),
              ),
            ),
            Positioned(
              top: 224,
              left: 80,
              right: 80,
              bottom: 392,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _dishes.isEmpty
                  ? Center(
                      child: Text(
                        'Menu belum tersedia',
                        style: totalStyle.copyWith(color: VMColorTheme.neutral),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (
                          var index = 0;
                          index < _dishes.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 40),
                          MenuDishCard(
                            dish: _dishes[index],
                            selected: _order.contains(_dishes[index]),
                            quantity: widget.quantityPerItem,
                            onOrder:
                                !_order.contains(_dishes[index]) &&
                                    _order.length >= widget.maxSelectedItems
                                ? null
                                : () => setState(() {
                                    final dish = _dishes[index];
                                    if (!_order.remove(dish) &&
                                        _order.length <
                                            widget.maxSelectedItems) {
                                      _order.add(dish);
                                    }
                                  }),
                          ),
                        ],
                      ],
                    ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: VMFooterContent(
                height: 312,
                cornerRadius: 24,
                padding: const EdgeInsets.all(80),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pesanan', style: totalStyle),
                        Semantics(
                          liveRegion: true,
                          child: Text(formatRupiah(total), style: totalStyle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: _order.isEmpty
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
                      child: VMButton(
                        label: 'Bayar Sekarang',
                        style: ButtonStyle(
                          backgroundColor: _order.isEmpty
                              ? null
                              : const WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                          foregroundColor: WidgetStatePropertyAll(
                            VMColorTheme.neutral,
                          ),
                          textStyle: WidgetStatePropertyAll(
                            TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 28 / 24,
                            ),
                          ),
                        ),
                        size: VMButtonSize.large,
                        expand: true,
                        onPressed: _order.isEmpty || widget.onCheckout == null
                            ? null
                            : () => widget.onCheckout!(
                                List.unmodifiable(
                                  _order.expand(
                                    (dish) => List.filled(
                                      widget.quantityPerItem,
                                      dish,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
