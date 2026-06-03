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

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        ratings: (json['ratings'] ?? 0).toDouble(),
        images: (json['images'] as List<dynamic>? ?? [])
            .map((i) => ProductImage.fromJson(i))
            .toList(),
        category: json['category'] ?? '',
        seller: json['seller'] ?? '',
        stock: json['stock'] ?? 0,
        numOfReviews: json['numOfReviews'] ?? 0,
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
        userId: json['user'] ?? '',
        rating: (json['rating'] ?? 0).toDouble(),
        comment: json['comment'] ?? '',
        name: json['name'] ?? '',
      );
}
