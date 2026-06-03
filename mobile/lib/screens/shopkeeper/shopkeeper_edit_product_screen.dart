import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/api_service.dart';
import '../../constants/api_constants.dart';

class ShopkeeperEditProductScreen extends StatefulWidget {
  const ShopkeeperEditProductScreen({super.key});

  @override
  State<ShopkeeperEditProductScreen> createState() =>
      _ShopkeeperEditProductScreenState();
}

class _ShopkeeperEditProductScreenState
    extends State<ShopkeeperEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _sellerCtrl = TextEditingController();
  String? _category;
  bool _saving = false;
  bool _uploading = false;

  late ProductModel _product;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _product =
          ModalRoute.of(context)!.settings.arguments as ProductModel;
      _nameCtrl.text = _product.name;
      _descCtrl.text = _product.description;
      _priceCtrl.text = _product.price.toString();
      _stockCtrl.text = _product.stock.toString();
      _sellerCtrl.text = _product.seller;
      _category = _product.category;
      _initialized = true;
    }
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ProductService.updateShopkeeperProduct(
        id: _product.id,
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
            content: Text('Product updated!'), backgroundColor: Colors.green),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 60);
    if (picked.isEmpty) return;
    if (picked.length > 4) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Maximum 4 images allowed'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() => _uploading = true);
    try {
      final base64Images = await Future.wait(picked.map((xf) async {
        final bytes = await File(xf.path).readAsBytes();
        final b64 = base64Encode(bytes);
        final ext = xf.path.split('.').last.toLowerCase();
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        return 'data:$mime;base64,$b64';
      }));

      await ProductService.uploadShopkeeperProductImages(
          _product.id, base64Images);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Images uploaded!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ApiService.extractMessage(e)),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current images + upload button
              if (_product.images.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _product.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _product.images[i].url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickAndUploadImages,
                icon: _uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.image_outlined),
                label: Text(_uploading
                    ? 'Uploading…'
                    : 'Upload Product Images (max 4)'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.inventory_2_outlined)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Price (₹)',
                    prefixIcon: Icon(Icons.currency_rupee)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined)),
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
                    prefixIcon: Icon(Icons.warehouse_outlined)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Whole number required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sellerCtrl,
                decoration: const InputDecoration(
                    labelText: 'Seller / Brand Name',
                    prefixIcon: Icon(Icons.storefront_outlined)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving…' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
