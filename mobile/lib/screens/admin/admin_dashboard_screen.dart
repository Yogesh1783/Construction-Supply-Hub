import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _productCount = 0;
  int _orderCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await ProductService.getAdminProducts();
      final orders = await OrderService.getAdminOrders();
      if (mounted) {
        setState(() {
          _productCount = products.length;
          _orderCount = orders.length;
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
        title: const Text('Admin Dashboard'),
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
                  Text('Welcome, ${user?.name ?? 'Admin'}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _statCard('Products', _productCount,
                              Icons.inventory, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _statCard(
                              'Orders', _orderCount, Icons.receipt, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Manage',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _menuCard(
                    icon: Icons.inventory_2,
                    title: 'Products',
                    subtitle: 'View, add, edit, delete products',
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin/products'),
                  ),
                  _menuCard(
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    subtitle: 'View and manage all orders',
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin/orders'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text('$count',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color)),
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
          backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF1565C0)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
