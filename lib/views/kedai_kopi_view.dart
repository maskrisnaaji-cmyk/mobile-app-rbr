import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/menu_item_card.dart';
import 'pesanan_meja_view.dart';

class KedaiKopiView extends StatefulWidget {
  const KedaiKopiView({super.key});

  @override
  State<KedaiKopiView> createState() => _KedaiKopiViewState();
}

class _KedaiKopiViewState extends State<KedaiKopiView> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Semua',
    'Espresso-Based',
    'Manual Brew',
    'Non-Coffee',
  ];

  final Map<String, int> _itemCounts = {
    'Kopi Susu Creamy': 0,
    'Americano Signature': 0,
    'Kopi Tubruk Budaya': 1,
  };

  final Map<String, int> _itemPrices = {
    'Kopi Susu Creamy': 18000,
    'Americano Signature': 17000,
    'Kopi Tubruk Budaya': 18000,
  };

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
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search_rounded, color: AppColors.greyText, size: 20),
                        hintText: 'Cari menu kopi atau camilan...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.greyText,
                        ),
                        border: InputBorder.none,
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
                  child: ListView(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                    children: [
                      MenuItemCard(
                        name: 'Kopi Susu Creamy',
                        price: 18000,
                        imageColor: Colors.orange,
                        count: _itemCounts['Kopi Susu Creamy'] ?? 0,
                        onAdd: () => _incrementItem('Kopi Susu Creamy'),
                        onRemove: () => _decrementItem('Kopi Susu Creamy'),
                      ),
                      MenuItemCard(
                        name: 'Americano Signature',
                        price: 17000,
                        imageColor: Colors.brown[700]!,
                        count: _itemCounts['Americano Signature'] ?? 0,
                        onAdd: () => _incrementItem('Americano Signature'),
                        onRemove: () => _decrementItem('Americano Signature'),
                      ),
                      MenuItemCard(
                        name: 'Kopi Tubruk Budaya',
                        price: 18000,
                        imageColor: Colors.grey[850]!,
                        count: _itemCounts['Kopi Tubruk Budaya'] ?? 0,
                        onAdd: () => _incrementItem('Kopi Tubruk Budaya'),
                        onRemove: () => _decrementItem('Kopi Tubruk Budaya'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Floating Bottom Bar untuk BAYAR
            if (_totalItems > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
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
                            color: AppColors.maroon.withValues(alpha: 0.3),
                            blurRadius: 15,
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
          ],
        ),
      ),
    );
  }
}