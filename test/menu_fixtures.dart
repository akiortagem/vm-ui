import 'package:vm_ui/features/menu_selection/domain/menu_dish.dart';
import 'package:vm_ui/features/menu_selection/domain/menu_repository.dart';
import 'package:vm_ui/features/menu_selection/domain/load_menu.dart';

// Display data from the Figma Menu Selection landing frame.
const menuDishes = [
  MenuDish(
    name: 'Nasi Goreng Kampung',
    price: 20000,
    imageAsset: 'lib/core/ui_kit/assets/menu/nasi_goreng_kampung.png',
    isBestSeller: true,
  ),
  MenuDish(
    name: 'Nasi Goreng Rendang',
    price: 28000,
    imageAsset: 'lib/core/ui_kit/assets/menu/nasi_goreng_rendang.png',
  ),
  MenuDish(
    name: 'Nasi Goreng Hongkong',
    price: 22000,
    imageAsset: 'lib/core/ui_kit/assets/menu/nasi_goreng_hongkong.png',
  ),
];

class FixtureMenuRepository implements MenuRepository {
  @override
  Future<List<MenuDish>> loadMenu() async => menuDishes;
}

final fixtureLoadMenu = LoadMenu(FixtureMenuRepository());
