import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final CookieJar _cookieJar = CookieJar();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void init() {
    dio.interceptors.add(CookieManager(_cookieJar));
  }

  static String extractMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        return error.response?.data['message'] ?? 'An error occurred';
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Check your network.';
        default:
          return 'An error occurred';
      }
    }
    return error.toString();
  }
}
