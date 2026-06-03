import '../models/order_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class OrderService {
  static Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final res = await ApiService.dio.post(ApiConstants.newOrder, data: data);
    return OrderModel.fromJson(res.data['order']);
  }

  static Future<List<OrderModel>> getMyOrders() async {
    final res = await ApiService.dio.get(ApiConstants.myOrders);
    return (res.data['orders'] as List)
        .map((o) => OrderModel.fromJson(o))
        .toList();
  }

  static Future<OrderModel> getOrderById(String id) async {
    final res = await ApiService.dio.get('/orders/$id');
    return OrderModel.fromJson(res.data['order']);
  }

  static Future<List<OrderModel>> getAdminOrders() async {
    final res = await ApiService.dio.get(ApiConstants.adminOrders);
    return (res.data['orders'] as List)
        .map((o) => OrderModel.fromJson(o))
        .toList();
  }

  static Future<void> updateAdminOrderStatus(String id, String status) async {
    await ApiService.dio
        .put('/admin/orders/$id', data: {'status': status});
  }

  static Future<void> deleteAdminOrder(String id) async {
    await ApiService.dio.delete('/admin/orders/$id');
  }

  static Future<List<OrderModel>> getShopkeeperOrders() async {
    final res = await ApiService.dio.get(ApiConstants.shopkeeperOrders);
    return (res.data['orders'] as List)
        .map((o) => OrderModel.fromJson(o))
        .toList();
  }

  static Future<void> updateShopkeeperOrderStatus(
      String id, String status) async {
    await ApiService.dio
        .put('/shopkeeper/orders/$id', data: {'status': status});
  }
}
