class ApiConstants {
  // Switch between dev and prod by commenting/uncommenting:
  // --- DEVELOPMENT (Android emulator) ---
  // static const String baseUrl = 'http://10.0.2.2:4000/api/v1';
  // --- DEVELOPMENT (physical device — use your PC's local IP) ---
  // static const String baseUrl = 'http://192.168.1.X:4000/api/v1';
  // --- PRODUCTION (Render.com — replace with your actual URL after deploy) ---
  static const String baseUrl = 'https://construction-supply-hub-2no0.onrender.com/api/v1';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String forgotPassword = '/password/forgot';

  // User profile
  static const String myProfile = '/me';
  static const String updateProfile = '/me/update';
  static const String updatePassword = '/password/update';
  static const String uploadAvatar = '/me/upload_avatar';

  // Products
  static const String products = '/products';
  static const String adminProducts = '/admin/products';
  static const String shopkeeperProducts = '/shopkeeper/products';

  // Reviews
  static const String reviews = '/reviews';
  static const String canReview = '/can_review';

  // Orders
  static const String newOrder = '/orders/new';
  static const String myOrders = '/me/orders';
  static const String adminOrders = '/admin/orders';
  static const String shopkeeperOrders = '/shopkeeper/orders';

  // Admin user management
  static const String adminUsers = '/admin/users';

  // Seller
  static const String registerSeller = '/registerSeller';
  static const String adminSellers = '/admin/sellers';

  // Analytics
  static const String adminSales = '/admin/get_sales';
  static const String shopkeeperSales = '/shopkeeper/get_sales';

  // Payment
  static const String checkoutSession = '/payment/checkout_session';

  static const List<String> categories = [
    'Building Materials',
    'Structural Steel',
    'Roofing',
    'Plumbing',
    'Electricals',
    'Finishing',
    'Decorative',
    'Safety Equipment',
    'Power Tools',
    'Heavy Machinery',
  ];
}
