class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final UserAvatar? avatar;
  final String? shopName;
  final String? shopAddress;
  final String? pinCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.shopName,
    this.shopAddress,
    this.pinCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'user',
        avatar:
            json['avatar'] != null ? UserAvatar.fromJson(json['avatar']) : null,
        shopName: json['shopName'],
        shopAddress: json['shopAddress'],
        pinCode: json['pinCode'],
      );

  bool get isAdmin => role == 'admin';
  bool get isShopkeeper => role == 'shopkeeper';
}

class UserAvatar {
  final String publicId;
  final String url;

  UserAvatar({required this.publicId, required this.url});

  factory UserAvatar.fromJson(Map<String, dynamic> json) =>
      UserAvatar(publicId: json['public_id'] ?? '', url: json['url'] ?? '');
}
