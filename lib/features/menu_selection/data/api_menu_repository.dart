import 'dart:convert';

import 'package:vm_ui/core/network/api_client.dart';
import '../domain/menu_dish.dart';
import '../domain/menu_repository.dart';

class ApiMenuRepository implements MenuRepository {
  ApiMenuRepository(
    this._client, {
    String mediaServerUrl = const String.fromEnvironment('MEDIA_SERVER_URL'),
  }) : _mediaServerUrl = mediaServerUrl;

  final Future<ApiClient> Function() _client;
  final String _mediaServerUrl;
  late final Uri _mediaBaseUrl = _parseMediaBaseUrl(_mediaServerUrl);

  static Uri _parseMediaBaseUrl(String value) {
    final uri = Uri.parse(value.endsWith('/') ? value : '$value/');
    if (!['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError(
        'MEDIA_SERVER_URL must be an absolute HTTP(S) base URL',
      );
    }
    return uri;
  }

  String? _imageUrl(String? imagePath) {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }
    return _mediaBaseUrl
        .resolve(path.replaceFirst(RegExp(r'^/+'), ''))
        .toString();
  }

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
        return MenuDish(
          id: product['id'] as int,
          vendingMachineProductId: product['vending_machine_product_id'] as int,
          name: product['name'] as String,
          price: product['price'] as int,
          stockQuantity: product['stock_quantity'] as int,
          imageUrl: _imageUrl(product['image_path'] as String?),
          description: product['description'] as String?,
          isBestSeller: product['is_best_seller'] as bool?,
        );
      }),
    );
  }
}
