import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../services/api_service.dart';
import '../../constants/api_constants.dart';

class ShopkeeperAddProductScreen extends StatefulWidget {
  const ShopkeeperAddProductScreen({super.key});

  @override
  State<ShopkeeperAddProductScreen> createState() =>
      _ShopkeeperAddProductScreenState();
}

class _ShopkeeperAddProductScreenState
    extends State<ShopkeeperAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _sellerCtrl = TextEditingController();
  String? _category;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _sellerCtrl.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _sellerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ProductService.createShopkeeperProduct(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        category: _category!,
        stock: int.parse(_stockCtrl.text.trim()),
        seller: _sellerCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Product created!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ApiService.extractMessage(e)),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Price is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ApiConstants.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  prefixIcon: Icon(Icons.warehouse_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Stock is required';
                  if (int.tryParse(v) == null) return 'Enter a whole number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sellerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Seller / Brand Name',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Seller name is required' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_loading ? 'Creating...' : 'Create Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
