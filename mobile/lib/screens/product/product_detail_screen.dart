import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _loading = true;
  bool _canReview = false;
  int _imageIndex = 0;
  final _commentCtrl = TextEditingController();
  double _rating = 3.0;
  String? _productId;
  bool _firstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only run on the very first build — prevents re-triggering on every
    // theme / MediaQuery dependency change while the screen is open.
    if (_firstLoad) {
      _firstLoad = false;
      _productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_productId != null) _loadProduct(_productId!);
    }
  }

  Future<void> _loadProduct(String id) async {
    if (mounted) setState(() => _loading = true);
    try {
      final product = await ProductService.getById(id);
      if (mounted) {
        setState(() {
          _product = product;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    // Check review eligibility separately — requires auth, ignore if guest
    try {
      final canReview = await ProductService.canReview(id);
      if (mounted) setState(() => _canReview = canReview);
    } catch (_) {}
  }

  Future<void> _submitReview() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    try {
      await ProductService.submitReview(
        productId: _product!.id,
        rating: _rating,
        comment: _commentCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Review submitted!'),
              backgroundColor: Colors.green),
        );
        _commentCtrl.clear();
        if (_productId != null) _loadProduct(_productId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final p = _product!;
    final auth = context.watch<AuthProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(p.name, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image gallery
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: p.images.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: p.images[i].url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  if (p.images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          p.images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _imageIndex == i ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _imageIndex == i
                                  ? Colors.white
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfa9c23)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.stock > 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.stock > 0 ? 'In Stock (${p.stock})' : 'Out of Stock',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: p.ratings,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('${p.ratings.toStringAsFixed(1)} (${p.numOfReviews} reviews)'),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(p.description, style: const TextStyle(height: 1.5)),
                  const Divider(height: 24),
                  const Text('Shop Details',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _detailRow(Icons.store, p.shopName),
                  _detailRow(Icons.location_on, p.shopAddress),
                  _detailRow(Icons.local_post_office, 'PIN: ${p.pinCode}'),
                  _detailRow(Icons.category, p.category),
                  const Divider(height: 24),
                  // Reviews
                  const Text('Customer Reviews',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (p.reviews.isEmpty)
                    const Text('No reviews yet.',
                        style: TextStyle(color: Colors.grey)),
                  ...p.reviews.map((r) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(r.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  RatingBarIndicator(
                                    rating: r.rating,
                                    itemBuilder: (_, __) => const Icon(
                                        Icons.star,
                                        color: Colors.amber),
                                    itemCount: 5,
                                    itemSize: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(r.comment),
                            ],
                          ),
                        ),
                      )),
                  if (auth.isAuthenticated && _canReview) ...[
                    const Divider(height: 24),
                    const Text('Write a Review',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      itemBuilder: (_, __) =>
                          const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (r) => setState(() => _rating = r),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _submitReview,
                      child: const Text('Submit Review'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: p.stock > 0
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Cart'),
                  onPressed: () {
                    if (!auth.isAuthenticated) {
                      Navigator.pushNamed(context, '/login');
                      return;
                    }
                    cart.addItem(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Added to cart!'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
