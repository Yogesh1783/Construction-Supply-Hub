import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
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
import 'screens/shopkeeper/shopkeeper_dashboard_screen.dart';
import 'screens/shopkeeper/shopkeeper_products_screen.dart';
import 'screens/shopkeeper/shopkeeper_orders_screen.dart';
import 'screens/seller/become_seller_screen.dart';

void main() {
  ApiService.init();
  runApp(const CshApp());
}

class CshApp extends StatelessWidget {
  const CshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Construction Supply Hub',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFfa9c23),
            primary: const Color(0xFF232f3e),
            secondary: const Color(0xFFfa9c23),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF232f3e),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfa9c23),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFfa9c23), width: 2),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFfa9c23),
            primary: const Color(0xFF232f3e),
            secondary: const Color(0xFFfa9c23),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF131921),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfa9c23),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFfa9c23), width: 2),
            ),
          ),
        ),
        home: const _AppEntry(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/product-detail': (_) => const ProductDetailScreen(),
          '/cart': (_) => const CartScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/my-orders': (_) => const MyOrdersScreen(),
          '/order-detail': (_) => const OrderDetailScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/admin/dashboard': (_) => const AdminDashboardScreen(),
          '/admin/products': (_) => const AdminProductsScreen(),
          '/admin/orders': (_) => const AdminOrdersScreen(),
          '/shopkeeper/dashboard': (_) => const ShopkeeperDashboardScreen(),
          '/shopkeeper/products': (_) => const ShopkeeperProductsScreen(),
          '/shopkeeper/orders': (_) => const ShopkeeperOrdersScreen(),
          '/become-seller': (_) => const BecomeSellerScreen(),
        },
      ),
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
    // Try to restore session from cookie on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        // Only show splash on very first app load
        if (auth.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction, size: 72, color: Color(0xFFfa9c23)),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }
        // When loading (login/register in progress), keep showing
        // the current screen so it can display errors via SnackBar
        if (auth.isAuthenticated) {
          if (auth.isAdmin) return const AdminDashboardScreen();
          if (auth.isShopkeeper) return const ShopkeeperDashboardScreen();
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
