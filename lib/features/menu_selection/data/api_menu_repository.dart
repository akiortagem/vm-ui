import 'dart:convert';

import 'package:vm_ui/core/network/api_client.dart';
import '../domain/menu_dish.dart';
import '../domain/menu_repository.dart';

class ApiMenuRepository implements MenuRepository {
  ApiMenuRepository(this._client);

  final Future<ApiClient> Function() _client;

  @override
  Future<List<MenuDish>> loadMenu() async {
    final client = await _client();
    final machineId = client.machineId;
    if (machineId == null) {
      throw ApiException(401, 'Machine credentials are required');
    }
    final response = await client.get('vending-machines/$machineId/products');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final products = json['products'] as List<dynamic>? ?? [];
    return List.unmodifiable(
      products.map((value) {
        final product = value as Map<String, dynamic>;
        final image = product['image_url'] as String?;
        return MenuDish(
          id: product['id'] as int,
          vendingMachineProductId: product['vending_machine_product_id'] as int,
          name: product['name'] as String,
          price: product['price'] as int,
          stockQuantity: product['stock_quantity'] as int,
          imageUrl: image == null || image.trim().isEmpty
              ? null
              : client.baseUrl.resolve(image).toString(),
          description: product['description'] as String?,
          isBestSeller: product['is_best_seller'] as bool?,
        );
      }),
    );
  }
}
