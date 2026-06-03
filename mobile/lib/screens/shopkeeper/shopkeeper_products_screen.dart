import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class ShopkeeperProductsScreen extends StatefulWidget {
  const ShopkeeperProductsScreen({super.key});

  @override
  State<ShopkeeperProductsScreen> createState() =>
      _ShopkeeperProductsScreenState();
}

class _ShopkeeperProductsScreenState extends State<ShopkeeperProductsScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await ProductService.getShopkeeperProducts();
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ProductService.deleteShopkeeperProduct(id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.pushNamed(
              context, '/shopkeeper/add-product');
          if (added == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products yet'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _products.length,
                    itemBuilder: (_, i) {
                      final p = _products[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: p.firstImageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${p.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Color(0xFFfa9c23),
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Stock: ${p.stock}',
                                style: TextStyle(
                                    color: p.stock > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _delete(p.id, p.name),
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: p.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
