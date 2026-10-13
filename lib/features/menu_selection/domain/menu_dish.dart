class MenuDish {
  const MenuDish({
    required this.name,
    required this.price,
    this.id,
    this.vendingMachineProductId,
    this.stockQuantity,
    this.imageUrl,
    this.imageAsset,
    this.description,
    this.isBestSeller,
  });

  final int? id;
  final int? vendingMachineProductId;
  final int? stockQuantity;
  final String name;
  final int price;
  final String? imageUrl;
  final String? imageAsset;
  final String? description;
  final bool? isBestSeller;
}

String formatRupiah(int amount) =>
    'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
