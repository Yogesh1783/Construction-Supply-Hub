import '../models/product_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class ProductService {
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    String? keyword,
    String? category,
    String? pinCode,
    double? minPrice,
    double? maxPrice,
    double? ratings,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (keyword?.isNotEmpty == true) query['keyword'] = keyword;
    if (category?.isNotEmpty == true) query['category'] = category;
    if (pinCode?.isNotEmpty == true) query['pinCode'] = pinCode;
    if (minPrice != null) query['price[gte]'] = minPrice;
    if (maxPrice != null) query['price[lte]'] = maxPrice;
    if (ratings != null) query['ratings[gte]'] = ratings;

    final res = await ApiService.dio.get(
      ApiConstants.products,
      queryParameters: query,
    );
    return {
      'products': (res.data['products'] as List)
          .map((p) => ProductModel.fromJson(p))
          .toList(),
      'productsCount': res.data['productsCount'] ?? 0,
      'resPerPage': res.data['resPerPage'] ?? 10,
    };
  }

  static Future<ProductModel> getById(String id) async {
    final res = await ApiService.dio.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(res.data['product']);
  }

  static Future<bool> canReview(String productId) async {
    final res = await ApiService.dio.get(
      ApiConstants.canReview,
      queryParameters: {'productId': productId},
    );
    return res.data['canReview'] ?? false;
  }

  static Future<void> submitReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    await ApiService.dio.put(
      ApiConstants.reviews,
      data: {'productId': productId, 'rating': rating, 'comment': comment},
    );
  }

  // Admin product management
  static Future<List<ProductModel>> getAdminProducts() async {
    final res = await ApiService.dio.get(ApiConstants.adminProducts);
    return (res.data['products'] as List)
        .map((p) => ProductModel.fromJson(p))
        .toList();
  }

  static Future<void> deleteAdminProduct(String id) async {
    await ApiService.dio.delete('${ApiConstants.adminProducts}/$id');
  }

  // Shopkeeper product management
  static Future<List<ProductModel>> getShopkeeperProducts() async {
    final res = await ApiService.dio.get(ApiConstants.shopkeeperProducts);
    return (res.data['products'] as List)
        .map((p) => ProductModel.fromJson(p))
        .toList();
  }

  static Future<void> deleteShopkeeperProduct(String id) async {
    await ApiService.dio.delete('${ApiConstants.shopkeeperProducts}/$id');
  }
}
