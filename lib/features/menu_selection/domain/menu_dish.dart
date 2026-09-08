class MenuDish {
  const MenuDish({
    required this.name,
    required this.price,
    required this.imageAsset,
    this.isBestSeller = false,
  });
  final String name;
  final int price;
  final String imageAsset;
  final bool isBestSeller;
  String get description =>
      'Nasi goreng ala kampung dengan aroma harum smoky yang dimasak dengan telur, sayuran, dan daging ayam.';
}

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

String formatRupiah(int amount) =>
    'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
