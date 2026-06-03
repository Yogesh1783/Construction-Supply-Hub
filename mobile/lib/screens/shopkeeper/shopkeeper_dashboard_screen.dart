import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

class ShopkeeperDashboardScreen extends StatefulWidget {
  const ShopkeeperDashboardScreen({super.key});

  @override
  State<ShopkeeperDashboardScreen> createState() =>
      _ShopkeeperDashboardScreenState();
}

class _ShopkeeperDashboardScreenState
    extends State<ShopkeeperDashboardScreen> {
  int _productCount = 0;
  int _orderCount = 0;
  double _totalRevenue = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await ProductService.getShopkeeperProducts();
      final orders = await OrderService.getShopkeeperOrders();
      final revenue =
          orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
      if (mounted) {
        setState(() {
          _productCount = products.length;
          _orderCount = orders.length;
          _totalRevenue = revenue;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopkeeper Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${user?.name ?? 'Shopkeeper'}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (user?.shopName != null) ...[
                    const SizedBox(height: 4),
                    Text(user!.shopName!,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _statCard('Products', '$_productCount',
                              Icons.inventory, Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _statCard('Orders', '$_orderCount',
                              Icons.receipt, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _statCard(
                    'Total Revenue',
                    '₹${_totalRevenue.toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    Colors.purple,
                    wide: true,
                  ),
                  const SizedBox(height: 24),
                  const Text('Manage',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _menuCard(
                    icon: Icons.inventory_2,
                    title: 'My Products',
                    subtitle: 'View and manage your products',
                    onTap: () => Navigator.pushNamed(
                        context, '/shopkeeper/products'),
                  ),
                  _menuCard(
                    icon: Icons.receipt_long,
                    title: 'My Orders',
                    subtitle: 'View and update order status',
                    onTap: () =>
                        Navigator.pushNamed(context, '/shopkeeper/orders'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      {bool wide = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: wide
            ? Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      Text(label, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 8),
                  Text(value,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(label, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFfa9c23).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFfa9c23)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
