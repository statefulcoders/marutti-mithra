class ProductModel {
  final String name;
  final int points;
  final String shop;

  ProductModel({
    required this.name,
    required this.points,
    required this.shop,
  });

  @override
  String toString() {
    return 'ProductModel(name: $name, points: $points, shop: $shop)';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print("PARSING: $json");
    return ProductModel(
      name: json['name'] as String,
      points: int.tryParse(json['points']?.toString() ?? "") ?? 0,
      shop: json['shop'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points,
      'shop': shop,
    };
  }
}