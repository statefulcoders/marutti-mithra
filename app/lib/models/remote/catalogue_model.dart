class CatalogueModel {
  final String name;
  final String url;

  CatalogueModel({
    required this.name,
    required this.url
  });

  @override
  String toString() {
    return 'ProductModel(name: $name, points: $url)';
  }

  factory CatalogueModel.fromJson(Map<String, dynamic> json) {
    return CatalogueModel(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}