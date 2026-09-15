import 'menu_dish.dart';
import 'menu_repository.dart';

class LoadMenu {
  const LoadMenu(this._repository);
  final MenuRepository _repository;

  Future<List<MenuDish>> call() => _repository.loadMenu();
}
