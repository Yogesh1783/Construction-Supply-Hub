import 'api_service.dart';

class SellerService {
  static Future<void> registerSeller({
    required String shopName,
    required String shopAddress,
    required String pinCode,
  }) async {
    await ApiService.dio.post('/registerSeller', data: {
      'shopName': shopName,
      'shopAddress': shopAddress,
      'pinCode': pinCode,
    });
  }

  static Future<List<dynamic>> getSellerRequests() async {
    final res = await ApiService.dio.get('/admin/sellers');
    return res.data['sellers'] as List<dynamic>;
  }

  static Future<void> approveSeller(String id) async {
    await ApiService.dio.put('/admin/sellers/$id/approve');
  }

  static Future<void> deleteSeller(String id) async {
    await ApiService.dio.delete('/admin/sellers/$id');
  }
}
