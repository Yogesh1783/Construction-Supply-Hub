import '../models/user_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
  static Future<UserModel> login(String email, String password) async {
    final res = await ApiService.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(res.data['user']);
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await ApiService.dio.post(
      ApiConstants.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return UserModel.fromJson(res.data['user']);
  }

  static Future<void> logout() async {
    await ApiService.dio.get(ApiConstants.logout);
  }

  static Future<UserModel> getProfile() async {
    final res = await ApiService.dio.get(ApiConstants.myProfile);
    return UserModel.fromJson(res.data['user']);
  }

  static Future<void> forgotPassword(String email) async {
    await ApiService.dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  static Future<UserModel> updateProfile(String name, String email) async {
    final res = await ApiService.dio.put(
      ApiConstants.updateProfile,
      data: {'name': name, 'email': email},
    );
    return UserModel.fromJson(res.data['user']);
  }

  static Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiService.dio.put(
      ApiConstants.updatePassword,
      data: {'oldPassword': oldPassword, 'password': newPassword},
    );
  }
}
