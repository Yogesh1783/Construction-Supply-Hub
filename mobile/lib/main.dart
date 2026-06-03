import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/checkout_screen.dart';
import 'screens/order/my_orders_screen.dart';
import 'screens/order/order_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_seller_requests_screen.dart';
import 'screens/shopkeeper/shopkeeper_dashboard_screen.dart';
import 'screens/shopkeeper/shopkeeper_products_screen.dart';
import 'screens/shopkeeper/shopkeeper_orders_screen.dart';
import 'screens/shopkeeper/shopkeeper_add_product_screen.dart';
import 'screens/shopkeeper/shopkeeper_edit_product_screen.dart';
import 'screens/seller/become_seller_screen.dart';

// ── Shared brand colours ────────────────────────────────────────────
const _kNavy   = Color(0xFF232f3e);
const _kOrange = Color(0xFFfa9c23);
const _kDark   = Color(0xFF131921);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final cs = isDark
      ? const ColorScheme(
          brightness: Brightness.dark,
          primary:          _kNavy,
          onPrimary:        Colors.white,
          primaryContainer: Color(0xFF2c3e50),
          onPrimaryContainer: Colors.white,
          secondary:        _kOrange,
          onSecondary:      Colors.white,
          secondaryContainer: Color(0xFF3d2b00),
          onSecondaryContainer: Colors.white,
          surface:          Color(0xFF1e1e1e),
          onSurface:        Colors.white,
          error:            Color(0xFFcf6679),
          onError:          Colors.black,
        )
      : const ColorScheme(
          brightness: Brightness.light,
          primary:          _kNavy,
          onPrimary:        Colors.white,
          primaryContainer: Color(0xFFd6dde6),
          onPrimaryContainer: _kNavy,
          secondary:        _kOrange,
          onSecondary:      Colors.white,
          secondaryContainer: Color(0xFFfff0d6),
          onSecondaryContainer: Color(0xFF3d2b00),
          surface:          Colors.white,
          onSurface:        Colors.black87,
          error:            Color(0xFFb00020),
          onError:          Colors.white,
        );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? _kDark : _kNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kOrange, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: _kOrange.withOpacity(0.2),
      labelStyle: const TextStyle(fontSize: 13),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _kOrange,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _kOrange,
    ),
  );
}

void main() {
  ApiService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const CshApp(),
    ),
  );
}

class CshApp extends StatelessWidget {
  const CshApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      title: 'Construction Supply Hub',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const _AppEntry(),
      routes: {
        '/login':                    (_) => const LoginScreen(),
        '/register':                 (_) => const RegisterScreen(),
        '/home':                     (_) => const HomeScreen(),
        '/product-detail':           (_) => const ProductDetailScreen(),
        '/cart':                     (_) => const CartScreen(),
        '/checkout':                 (_) => const CheckoutScreen(),
        '/my-orders':                (_) => const MyOrdersScreen(),
        '/order-detail':             (_) => const OrderDetailScreen(),
        '/profile':                  (_) => const ProfileScreen(),
        '/admin/dashboard':          (_) => const AdminDashboardScreen(),
        '/admin/products':           (_) => const AdminProductsScreen(),
        '/admin/orders':             (_) => const AdminOrdersScreen(),
        '/admin/seller-requests':    (_) => const AdminSellerRequestsScreen(),
        '/shopkeeper/dashboard':     (_) => const ShopkeeperDashboardScreen(),
        '/shopkeeper/products':      (_) => const ShopkeeperProductsScreen(),
        '/shopkeeper/orders':        (_) => const ShopkeeperOrdersScreen(),
        '/shopkeeper/add-product':   (_) => const ShopkeeperAddProductScreen(),
        '/shopkeeper/edit-product':  (_) => const ShopkeeperEditProductScreen(),
        '/become-seller':            (_) => const BecomeSellerScreen(),
      },
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();
  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.status == AuthStatus.initial) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.construction, size: 72, color: _kOrange),
                  const SizedBox(height: 16),
                  const Text(
                    'Construction Supply Hub',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: _kOrange),
                ],
              ),
            ),
          );
        }
        if (auth.isAuthenticated) {
          if (auth.isAdmin) return const AdminDashboardScreen();
          if (auth.isShopkeeper) return const ShopkeeperDashboardScreen();
          return const HomeScreen();
        }
        // Guests can browse products without logging in
        return const HomeScreen();
      },
    );
  }
}
