class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final double ratings;
  final List<ProductImage> images;
  final String category;
  final String seller;
  final int stock;
  final int numOfReviews;
  final String pinCode;
  final String shopName;
  final String shopAddress;
  final String? shopkeeperId;
  final List<ProductReview> reviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.ratings,
    required this.images,
    required this.category,
    required this.seller,
    required this.stock,
    required this.numOfReviews,
    required this.pinCode,
    required this.shopName,
    required this.shopAddress,
    this.shopkeeperId,
    required this.reviews,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
  static int _toInt(dynamic v) =>
      v == null ? 0 : int.tryParse(v.toString()) ?? 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        price: ProductModel._toDouble(json['price']),
        description: json['description'] ?? '',
        ratings: ProductModel._toDouble(json['ratings']),
        images: (json['images'] as List<dynamic>? ?? [])
            .map((i) => ProductImage.fromJson(i))
            .toList(),
        category: json['category']?.toString() ?? '',
        seller: json['seller']?.toString() ?? '',
        stock: ProductModel._toInt(json['stock']),
        numOfReviews: ProductModel._toInt(json['numOfReviews']),
        pinCode: json['pinCode'] ?? '',
        shopName: json['shopName'] ?? '',
        shopAddress: json['shopAddress'] ?? '',
        shopkeeperId: json['shopkeeperId'] is Map
            ? json['shopkeeperId']['_id']
            : json['shopkeeperId'],
        reviews: (json['reviews'] as List<dynamic>? ?? [])
            .map((r) => ProductReview.fromJson(r))
            .toList(),
      );

  String get firstImageUrl => images.isNotEmpty
      ? images[0].url
      : 'https://placehold.co/300x300?text=No+Image';
}

class ProductImage {
  final String publicId;
  final String url;

  ProductImage({required this.publicId, required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      ProductImage(publicId: json['public_id'] ?? '', url: json['url'] ?? '');
}

class ProductReview {
  final String userId;
  final double rating;
  final String comment;
  final String name;

  ProductReview({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.name,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        userId: json['user'] is Map
            ? (json['user']['_id'] ?? '').toString()
            : json['user']?.toString() ?? '',
        rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
        comment: json['comment']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}
