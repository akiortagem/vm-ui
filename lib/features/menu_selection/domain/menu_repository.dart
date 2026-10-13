import 'menu_dish.dart';

abstract interface class MenuRepository {
  Future<List<MenuDish>> loadMenu();
}
