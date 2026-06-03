import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int stock;
  final String shopName;
  final String shopkeeperId;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.stock,
    required this.shopName,
    required this.shopkeeperId,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0, (s, i) => s + i.price * i.quantity);
  double get taxAmount => subtotal * 0.18;
  double get shippingAmount => subtotal > 0 ? 50.0 : 0.0;
  double get totalAmount => subtotal + taxAmount + shippingAmount;

  void addItem(ProductModel product) {
    final idx = _items.indexWhere((i) => i.productId == product.id);
    if (idx >= 0) {
      if (_items[idx].quantity < product.stock) _items[idx].quantity++;
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        image: product.firstImageUrl,
        price: product.price,
        stock: product.stock,
        shopName: product.shopName,
        shopkeeperId: product.shopkeeperId ?? '',
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void increment(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0 && _items[idx].quantity < _items[idx].stock) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
