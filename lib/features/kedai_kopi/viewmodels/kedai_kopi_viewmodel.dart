import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/kedai_kopi/models/cart_item_model.dart';
import 'package:mobile_app/features/kedai_kopi/models/coupon_model.dart';
import 'package:mobile_app/features/kedai_kopi/models/menu_model.dart';
import 'package:mobile_app/features/kedai_kopi/repositories/kedai_kopi_repository.dart';

/// ViewModel untuk mengelola seluruh state dan logika bisnis fitur Kedai Kopi
class KedaiKopiViewModel extends ChangeNotifier {
  final KedaiKopiRepository repository;
  Timer? _autoRefreshTimer;

  KedaiKopiViewModel({KedaiKopiRepository? repository})
      : repository = repository ?? KedaiKopiRepositoryImpl();

  // ── State Menu & Filter ───────────────────────────────────────────────────
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedTableNumber;
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  List<MenuModel> _allMenuList = [];
  List<MenuModel> _filteredMenuList = [];
  List<CultureCoupon> _coupons = [];
  List<String> _categories = [
    'Semua',
    'Kopi Nusantara',
    'Manual Brew',
    'Non-Kopi',
    'Camilan Nusantara',
  ];

  // ── State Keranjang Belanja ───────────────────────────────────────────────
  final Map<String, int> _itemCounts = {};
  final Map<String, int> _itemPrices = {};

  // ── State Transaksi Pembayaran ────────────────────────────────────────────
  int _selectedPaymentMethod = 0; // 0: QRIS, 1: Bayar di Kasir (Tunai)
  bool _isSubmittingOrder = false;

  // ── Menu Fallback Default ─────────────────────────────────────────────────
  static final List<MenuModel> _defaultMenus = [
    MenuModel(
      name: 'Kopi Tubruk Nusantara',
      category: 'Manual Brew',
      price: 18000,
      image: 'assets/images/kopi_tubruk.jpg',
      description: 'Single Origin • Tubruk Tradisional',
    ),
    MenuModel(
      name: 'V60 Manual Brew',
      category: 'Manual Brew',
      price: 25000,
      image: 'assets/images/americano.jpg',
      description: 'Light Roast • Fruity Notes',
    ),
    MenuModel(
      name: 'Kopi Susu Creamy',
      category: 'Kopi Nusantara',
      price: 18000,
      image: 'assets/images/kopi_susu.jpg',
      description: 'Less Sugar • Less Ice',
    ),
    MenuModel(
      name: 'Americano Signature',
      category: 'Kopi Nusantara',
      price: 17000,
      image: 'assets/images/americano.jpg',
      description: 'Single Origin • Hot',
    ),
    MenuModel(
      name: 'Wedang Uwuh Kraton',
      category: 'Non-Kopi',
      price: 15000,
      image: 'assets/images/wedang_uwuh.jpg',
      description: 'Rempah Hangat Tradisional',
    ),
    MenuModel(
      name: 'Pisang Goreng Wijen',
      category: 'Camilan Nusantara',
      price: 15000,
      image: 'assets/images/pisang_goreng_keju.jpg',
      description: 'Garing & Manis Legit',
    ),
  ];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedTableNumber => _selectedTableNumber;
  String get searchQuery => _searchQuery;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<MenuModel> get allMenuList => _allMenuList;
  List<MenuModel> get filteredMenuList => _filteredMenuList;
  List<CultureCoupon> get coupons => List.unmodifiable(_coupons);
  List<String> get categories => _categories;
  Map<String, int> get itemCounts => Map.unmodifiable(_itemCounts);
  int get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isSubmittingOrder => _isSubmittingOrder;

  int get totalItems {
    int total = 0;
    _itemCounts.forEach((_, value) => total += value);
    return total;
  }

  int get totalPrice {
    int total = 0;
    _itemCounts.forEach((key, count) {
      total += (_itemPrices[key] ?? 0) * count;
    });
    return total;
  }

  /// Menghasilkan list [CartItem] dari item yang telah dipilih
  List<CartItem> get cartItems {
    final List<CartItem> items = [];
    for (var menu in _allMenuList) {
      final count = _itemCounts[menu.name] ?? 0;
      if (count > 0) {
        items.add(CartItem(
          name: menu.name,
          price: menu.price,
          quantity: count,
          note: menu.description.isNotEmpty
              ? menu.description
              : (menu.category == 'Manual Brew'
                  ? 'Single Origin • Panas'
                  : 'Pilihan Favorit'),
          image: menu.image,
          category: menu.category,
        ));
      }
    }
    // Item ekstra yang mungkin ada di _itemCounts namun tidak di _allMenuList
    _itemCounts.forEach((name, count) {
      if (count > 0 && !items.any((item) => item.name == name)) {
        items.add(CartItem(
          name: name,
          price: _itemPrices[name] ?? 0,
          quantity: count,
          note: 'Menu Pilihan',
        ));
      }
    });
    return items;
  }

  // ── Inisialisasi & Lifecycle ─────────────────────────────────────────────
  void init() {
    _allMenuList = List.from(_defaultMenus);
    for (var item in _defaultMenus) {
      _itemPrices[item.name] = item.price;
      _itemCounts[item.name] = 0;
    }
    _applyFilter();
    fetchMenus();
  }

  /// Memulai sinkronisasi otomatis status menu secara berkala
  void startAutoRefresh([Duration interval = const Duration(seconds: 4)]) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) {
      fetchMenus(silent: true);
    });
  }

  /// Menghentikan sinkronisasi otomatis
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  // ── Aksi & Logika Menu ────────────────────────────────────────────────────

  /// Mengambil daftar menu dari API (mendukung silent refresh agar UI tidak berkedip)
  Future<void> fetchMenus({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final menus = await repository.getMenus();
      if (menus.isNotEmpty) {
        final Set<String> cats = {'Semua'};
        for (var menu in menus) {
          cats.add(menu.category);
          _itemPrices[menu.name] = menu.price;
          _itemCounts.putIfAbsent(menu.name, () => 0);

          // Jika status menu berubah menjadi Habis, nolkan jumlah di keranjang
          if (!menu.isAvailable && (_itemCounts[menu.name] ?? 0) > 0) {
            _itemCounts[menu.name] = 0;
          }
        }
        _allMenuList = menus;
        _categories = cats.toList();
        _applyFilter();
      }
    } catch (_) {
      // Jika backend gagal, default menus / data yang sudah ada tetap dipakai
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> fetchCoupons() async {
    try {
      _coupons = await repository.getCoupons();
      notifyListeners();
    } catch (_) {
      // Checkout tetap dapat berjalan tanpa kupon jika API sedang tidak tersedia.
    }
  }

  /// Memperbarui query pencarian
  void updateSearch(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isNotEmpty && _selectedCategoryIndex != 0) {
      _selectedCategoryIndex = 0;
    }
    _applyFilter();
    notifyListeners();
  }

  /// Menghapus query pencarian
  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  /// Memilih kategori menu
  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    _applyFilter();
    notifyListeners();
  }

  /// Menyetel nomor meja
  void selectTable(int? tableNumber) {
    _selectedTableNumber = tableNumber;
    notifyListeners();
  }

  /// Menambah jumlah menu ke keranjang (dicegah jika menu berstatus habis)
  void incrementItem(String name) {
    final menu = _allMenuList.cast<MenuModel?>().firstWhere(
          (m) => m?.name == name,
          orElse: () => null,
        );
    // Cegah penambahan jika menu habis
    if (menu != null && !menu.isAvailable) {
      return;
    }
    _itemCounts[name] = (_itemCounts[name] ?? 0) + 1;
    notifyListeners();
  }

  /// Menambahkan menu ke keranjang (hanya jika menu tersedia)
  void addToCart(MenuModel menu) {
    if (!menu.isAvailable) return;
    incrementItem(menu.name);
  }

  /// Mengurangi jumlah menu dari keranjang
  void decrementItem(String name) {
    if ((_itemCounts[name] ?? 0) > 0) {
      _itemCounts[name] = (_itemCounts[name] ?? 0) - 1;
      notifyListeners();
    }
  }

  /// Mengosongkan keranjang
  void clearCart() {
    _itemCounts.clear();
    notifyListeners();
  }

  // ── Aksi & Logika Transaksi Pesanan Meja ───────────────────────────────────

  /// Memilih metode pembayaran
  void selectPaymentMethod(int method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  /// Mengirim transaksi charge pesanan kedai
  Future<Map<String, dynamic>?> submitOrderTransaction({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String paymentType,
    String bank = '',
    required List<CartItem> items,
    String? couponCode,
    dynamic userId,
  }) async {
    _isSubmittingOrder = true;
    notifyListeners();
    try {
      final result = await repository.submitOrder(
        orderId: orderId,
        grossAmount: grossAmount,
        customerName: customerName,
        paymentType: paymentType,
        bank: bank,
        items: items,
        couponCode: couponCode,
        userId: userId,
      );
      return result;
    } finally {
      _isSubmittingOrder = false;
      notifyListeners();
    }
  }

  /// Mendaftarkan pesanan baru ke backend kedai (status: UNPAID)
  Future<Map<String, dynamic>?> createKedaiOrder({
    required String orderCode,
    required String tableNumber,
    required List<CartItem> items,
    required int totalPrice,
  }) async {
    try {
      return await repository.createKedaiOrder(
        orderCode: orderCode,
        tableNumber: tableNumber,
        items: items,
        totalPrice: totalPrice,
      );
    } catch (_) {
      return null;
    }
  }

  /// Mengkonfirmasi pembayaran pesanan kedai (payment_status → PAID)
  Future<bool> confirmKedaiOrderPayment(String orderCode) async {
    try {
      return await repository.confirmKedaiOrderPayment(orderCode);
    } catch (_) {
      return false;
    }
  }

  // ── Helper Internal ───────────────────────────────────────────────────────
  void _applyFilter() {
    final selectedCat = _selectedCategoryIndex < _categories.length
        ? _categories[_selectedCategoryIndex]
        : 'Semua';
    _filteredMenuList = _allMenuList.where((menu) {
      final nameMatches = menu.name.toLowerCase().contains(_searchQuery);
      final categoryMatches =
          menu.category.toLowerCase().contains(_searchQuery);
      final descMatches =
          menu.description.toLowerCase().contains(_searchQuery);
      final matchesSearch =
          _searchQuery.isEmpty || nameMatches || categoryMatches || descMatches;
      final matchesCategory =
          selectedCat == 'Semua' || menu.category == selectedCat;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}
