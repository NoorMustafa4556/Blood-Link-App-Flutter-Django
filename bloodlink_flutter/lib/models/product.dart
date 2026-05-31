class Product {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? image;
  final int? categoryId;
  final String? categoryName;
  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    this.categoryId,
    this.categoryName,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      image: json['image'],
      categoryId: json['category'],
      categoryName: json['category_name'],
    );
  }
}
