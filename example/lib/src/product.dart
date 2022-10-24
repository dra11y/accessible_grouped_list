class Product {
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final int price;
  final double rating;
  final String category;
  final String thumbnail;
  final List<String>? images;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        price: json['price'],
        rating: double.parse(json['rating'].toString()),
        category: json['category'],
        thumbnail: json['thumbnail'],
        images: (json['images'] as List<dynamic>?)
            ?.map((i) => i.toString())
            .toList(),
      );
}
