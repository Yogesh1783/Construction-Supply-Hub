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
}
