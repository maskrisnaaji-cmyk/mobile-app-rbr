import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/colors.dart';
import '../widgets/menu_item_card.dart';
import 'pesanan_meja_view.dart';

class KedaiMenuItem {
  final String name;
  final String category;
  final int price;
  final String image;
  final Color imageColor;

  const KedaiMenuItem({
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.imageColor,
  });
}

class KedaiKopiView extends StatefulWidget {
  const KedaiKopiView({super.key});

  @override
  State<KedaiKopiView> createState() => _KedaiKopiViewState();
}

class _KedaiKopiViewState extends State<KedaiKopiView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoading = true;

  List<KedaiMenuItem> _allMenuList = [];
  List<KedaiMenuItem> _filteredMenuList = [];

  int _selectedCategoryIndex = 0;
  List<String> _categories = [
    'Semua',
    'Kopi Nusantara',
    'Manual Brew',
    'Non-Kopi',
    'Camilan Nusantara',
  ];

  final Map<String, int> _itemCounts = {};
  final Map<String, int> _itemPrices = {};

  @override
  void initState() {
    super.initState();
    _filteredMenuList = [];
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.menusUrl)).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<KedaiMenuItem> loaded = [];
        final Set<String> categories = {'Semua'};

        for (var item in data) {
          final name = item['name']?.toString() ?? '';
          final category = item['category']?.toString() ?? 'Kopi Nusantara';
          final price = int.tryParse(item['price']?.toString() ?? '') ?? 0;
          final image = item['image']?.toString() ?? '';

          categories.add(category);
          loaded.add(KedaiMenuItem(
            name: name,
            category: category,
            price: price,
            image: image,
            imageColor: _colorForCategory(category),
          ));

          _itemPrices[name] = price;
          _itemCounts.putIfAbsent(name, () => 0);
        }

        if (mounted) {
          setState(() {
            _allMenuList = loaded;
            _categories = categories.toList();
            _applyFilter();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'kopi nusantara':
      case 'espresso-based':
        return Colors.brown.shade700;
      case 'manual brew':
        return Colors.brown.shade900;
      case 'non-kopi':
      case 'non-coffee':
        return Colors.teal.shade800;
      case 'camilan nusantara':
      case 'snack':
        return Colors.orange.shade800;
      default:
        return AppColors.maroon;
    }
  }

  void _applyFilter() {
    final selectedCat = _selectedCategoryIndex < _categories.length ? _categories[_selectedCategoryIndex] : 'Semua';
    _filteredMenuList = _allMenuList.where((menu) {
      final nameMatches = menu.name.toLowerCase().contains(_searchQuery);
      final categoryMatches = menu.category.toLowerCase().contains(_searchQuery);
      final matchesSearch = _searchQuery.isEmpty || nameMatches || categoryMatches;
      final matchesCategory = selectedCat == 'Semua' || menu.category == selectedCat;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _incrementItem(String name) {
    setState(() {
      _itemCounts[name] = (_itemCounts[name] ?? 0) + 1;
    });
  }

  void _decrementItem(String name) {
    setState(() {
      if ((_itemCounts[name] ?? 0) > 0) {
        _itemCounts[name] = (_itemCounts[name] ?? 0) - 1;
      }
    });
  }

  int get _totalItems {
    int total = 0;
    _itemCounts.forEach((_, value) => total += value);
    return total;
  }

  int get _totalPrice {
    int total = 0;
    _itemCounts.forEach((key, count) {
      total += (_itemPrices[key] ?? 0) * count;
    });
    return total;
  }

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.maroon,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Kedai Kopi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search_rounded, color: AppColors.darkText),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.darkText),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Card Status Meja
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.chair_alt_rounded, color: AppColors.maroon, size: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KEDAI & GALERI',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.greyText,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Meja No. 04',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Terhubung',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                          if (_searchQuery.isNotEmpty && _selectedCategoryIndex != 0) {
                            _selectedCategoryIndex = 0;
                          }
                          _applyFilter();
                        });
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search_rounded, color: AppColors.greyText, size: 20),
                        hintText: 'Cari menu kopi atau camilan...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.greyText,
                        ),
                        border: InputBorder.none,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.greyText, size: 18),
                                splashRadius: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = "";
                                    _applyFilter();
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Kategori Filter
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_categories[index]),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                              _applyFilter();
                            });
                          },
                          selectedColor: AppColors.maroon,
                          backgroundColor: Colors.white,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.darkText,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.maroon : AppColors.lightBorder,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Daftar Menu List
                Expanded(
                  child: _isLoading && _allMenuList.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.maroon),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchMenus,
                          color: AppColors.maroon,
                          child: _filteredMenuList.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.cardBg,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.lightBorder),
                                            ),
                                            child: const Icon(
                                              Icons.search_off_rounded,
                                              size: 36,
                                              color: AppColors.greyText,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Menu tidak ditemukan',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _searchQuery.isNotEmpty
                                                ? 'Menu dengan kata kunci "$_searchQuery" tidak ditemukan. Coba kata kunci lain.'
                                                : 'Tidak ada menu pada kategori ini.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AppColors.greyText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                                  itemCount: _filteredMenuList.length,
                                  itemBuilder: (context, index) {
                                    final menu = _filteredMenuList[index];
                                    return MenuItemCard(
                                      name: menu.name,
                                      price: menu.price,
                                      image: menu.image,
                                      imageColor: menu.imageColor,
                                      count: _itemCounts[menu.name] ?? 0,
                                      onAdd: () => _incrementItem(menu.name),
                                      onRemove: () => _decrementItem(menu.name),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),

            // Floating Bottom Bar untuk BAYAR (Hanya muncul jika user telah menambah pesanan)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                offset: _totalItems > 0 ? Offset.zero : const Offset(0, 1.5),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _totalItems > 0 ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: _totalItems == 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PesananMejaView(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.maroon,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.maroon.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$_totalItems Item • Meja 04',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupiah(_totalPrice),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'BAYAR',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}