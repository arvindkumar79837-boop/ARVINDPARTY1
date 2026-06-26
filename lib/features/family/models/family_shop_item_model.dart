class FamilyShopItemModel {
  final String itemId;
  final String name;
  final String itemType;
  final String rarity;
  final int priceFamilyPoints;
  final int priceCoins;
  final String imageUrl;
  final String description;
  final int requiredLevel;
  final bool isActive;
  final int stock;
  final DateTime createdAt;

  FamilyShopItemModel({
    required this.itemId,
    required this.name,
    required this.itemType,
    required this.rarity,
    required this.priceFamilyPoints,
    required this.priceCoins,
    required this.imageUrl,
    required this.description,
    required this.requiredLevel,
    required this.isActive,
    required this.stock,
    required this.createdAt,
  });

  factory FamilyShopItemModel.fromJson(Map<String, dynamic> json) {
    return FamilyShopItemModel(
      itemId: json['itemId'] ?? '',
      name: json['name'] ?? '',
      itemType: json['itemType'] ?? 'frame',
      rarity: json['rarity'] ?? 'common',
      priceFamilyPoints: json['priceFamilyPoints'] ?? 0,
      priceCoins: json['priceCoins'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      requiredLevel: json['requiredLevel'] ?? 1,
      isActive: json['isActive'] ?? true,
      stock: json['stock'] ?? -1,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'itemType': itemType,
      'rarity': rarity,
      'priceFamilyPoints': priceFamilyPoints,
      'priceCoins': priceCoins,
      'imageUrl': imageUrl,
      'description': description,
      'requiredLevel': requiredLevel,
      'isActive': isActive,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}