class OrderModel {
  final String id;
  final ShippingInfo shippingInfo;
  final String userId;
  final String shopKeeperId;
  final List<OrderItem> orderItems;
  final String paymentMethod;
  final PaymentInfo? paymentInfo;
  final double itemsPrice;
  final double taxAmount;
  final double shippingAmount;
  final double totalAmount;
  final String orderStatus;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.shippingInfo,
    required this.userId,
    required this.shopKeeperId,
    required this.orderItems,
    required this.paymentMethod,
    this.paymentInfo,
    required this.itemsPrice,
    required this.taxAmount,
    required this.shippingAmount,
    required this.totalAmount,
    required this.orderStatus,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['_id'] ?? '',
        shippingInfo: ShippingInfo.fromJson(json['shippingInfo'] ?? {}),
        userId: json['user'] is Map
            ? json['user']['_id'] ?? ''
            : json['user'] ?? '',
        shopKeeperId: json['shopKeeperId'] is Map
            ? json['shopKeeperId']['_id'] ?? ''
            : json['shopKeeperId'] ?? '',
        orderItems: (json['orderItems'] as List<dynamic>? ?? [])
            .map((i) => OrderItem.fromJson(i))
            .toList(),
        paymentMethod: json['paymentMethod'] ?? 'COD',
        paymentInfo: json['paymentInfo'] != null
            ? PaymentInfo.fromJson(json['paymentInfo'])
            : null,
        itemsPrice: (json['itemsPrice'] ?? 0).toDouble(),
        taxAmount: (json['taxAmount'] ?? 0).toDouble(),
        shippingAmount: (json['shippingAmount'] ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        orderStatus: json['orderStatus'] ?? 'Processing',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class ShippingInfo {
  final String address;
  final String city;
  final String phoneNo;
  final String zipCode;
  final String country;

  ShippingInfo({
    required this.address,
    required this.city,
    required this.phoneNo,
    required this.zipCode,
    required this.country,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) => ShippingInfo(
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        phoneNo: json['phoneNo'] ?? '',
        zipCode: json['zipCode'] ?? '',
        country: json['country'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'phoneNo': phoneNo,
        'zipCode': zipCode,
        'country': country,
      };
}

class OrderItem {
  final String name;
  final int quantity;
  final String image;
  final double price;
  final String productId;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.image,
    required this.price,
    required this.productId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        image: json['image'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        productId: json['product'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'image': image,
        'price': price,
        'product': productId,
      };
}

class PaymentInfo {
  final String id;
  final String status;

  PaymentInfo({required this.id, required this.status});

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      PaymentInfo(id: json['id'] ?? '', status: json['status'] ?? '');
}
