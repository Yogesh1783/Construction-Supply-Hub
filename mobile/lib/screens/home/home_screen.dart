import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../../constants/api_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<ProductModel> _products = [];
  bool _loading = false;
  int _currentPage = 1;
  int _totalCount = 0;
  int _resPerPage = 10;
  String? _selectedCategory;
  String? _pinCode;
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({bool reset = true}) async {
    if (reset) _currentPage = 1;
    setState(() => _loading = true);
    try {
      final result = await ProductService.getProducts(
        page: _currentPage,
        keyword: _searchCtrl.text.trim(),
        category: _selectedCategory,
        pinCode: _pinCode,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      setState(() {
        _products = result['products'];
        _totalCount = result['productsCount'];
        _resPerPage = result['resPerPage'];
      });
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

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FiltersSheet(
        selectedCategory: _selectedCategory,
        pinCode: _pinCode,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (cat, pin, min, max) {
          setState(() {
            _selectedCategory = cat;
            _pinCode = pin;
            _minPrice = min;
            _maxPrice = max;
          });
          _fetchProducts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CSH Store'),
        actions: [
          badges.Badge(
            badgeContent: Text('$cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 10)),
            showBadge: cartCount > 0,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.person),
            itemBuilder: (_) => [
              if (auth.isAuthenticated) ...[
                const PopupMenuItem(value: 'profile', child: Text('Profile')),
                const PopupMenuItem(value: 'orders', child: Text('My Orders')),
                if (auth.isAdmin)
                  const PopupMenuItem(
                      value: 'admin', child: Text('Admin Dashboard')),
                if (auth.isShopkeeper)
                  const PopupMenuItem(
                      value: 'shopkeeper',
                      child: Text('Shopkeeper Dashboard')),
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ] else ...[
                const PopupMenuItem(value: 'login', child: Text('Login')),
                const PopupMenuItem(
                    value: 'register', child: Text('Register')),
              ],
            ],
            onSelected: (val) async {
              switch (val) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'orders':
                  Navigator.pushNamed(context, '/my-orders');
                  break;
                case 'admin':
                  Navigator.pushNamed(context, '/admin/dashboard');
                  break;
                case 'shopkeeper':
                  Navigator.pushNamed(context, '/shopkeeper/dashboard');
                  break;
                case 'login':
                  Navigator.pushNamed(context, '/login');
                  break;
                case 'register':
                  Navigator.pushNamed(context, '/register');
                  break;
                case 'logout':
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onSubmitted: (_) => _fetchProducts(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFfa9c23),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedCategory != null || _pinCode != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!),
                      onDeleted: () {
                        setState(() => _selectedCategory = null);
                        _fetchProducts();
                      },
                    ),
                  const SizedBox(width: 8),
                  if (_pinCode != null)
                    Chip(
                      label: Text('PIN: $_pinCode'),
                      onDeleted: () {
                        setState(() => _pinCode = null);
                        _fetchProducts();
                      },
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_totalCount products found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No products found'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (_, i) => ProductCard(
                            product: _products[i],
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/product-detail',
                              arguments: _products[i].id,
                            ),
                          ),
                        ),
                      ),
          ),
          if (_totalCount > _resPerPage)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            _currentPage--;
                            _fetchProducts(reset: false);
                          }
                        : null,
                  ),
                  Text('Page $_currentPage'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _resPerPage < _totalCount
                        ? () {
                            _currentPage++;
                            _fetchProducts(reset: false);
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final String? selectedCategory;
  final String? pinCode;
  final double? minPrice;
  final double? maxPrice;
  final Function(String?, String?, double?, double?) onApply;

  const _FiltersSheet({
    this.selectedCategory,
    this.pinCode,
    this.minPrice,
    this.maxPrice,
    required this.onApply,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String? _category;
  final _pinCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _pinCtrl.text = widget.pinCode ?? '';
    _minCtrl.text = widget.minPrice?.toString() ?? '';
    _maxCtrl.text = widget.maxPrice?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            hint: const Text('Select Category'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Categories')),
              ...ApiConstants.categories.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pinCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PIN Code',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min Price',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Price',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply(null, null, null, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _category,
                      _pinCtrl.text.isEmpty ? null : _pinCtrl.text,
                      _minCtrl.text.isEmpty
                          ? null
                          : double.tryParse(_minCtrl.text),
                      _maxCtrl.text.isEmpty
                          ? null
                          : double.tryParse(_maxCtrl.text),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
