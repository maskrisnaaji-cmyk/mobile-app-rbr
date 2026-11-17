import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/features/kedai_kopi/viewmodels/kedai_kopi_viewmodel.dart';
import 'package:mobile_app/features/kedai_kopi/views/pesanan_meja_view.dart';
import 'package:mobile_app/features/kedai_kopi/widgets/menu_item_card.dart';

class _CoffeeTable {
  final int number;
  final bool isOccupied;

  const _CoffeeTable({required this.number, required this.isOccupied});
}

class KedaiKopiView extends StatefulWidget {
  final KedaiKopiViewModel? viewModel;

  const KedaiKopiView({super.key, this.viewModel});

  @override
  State<KedaiKopiView> createState() => _KedaiKopiViewState();
}

class _KedaiKopiViewState extends State<KedaiKopiView> {
  late final KedaiKopiViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  static const List<_CoffeeTable> _tables = [
    _CoffeeTable(number: 1, isOccupied: false),
    _CoffeeTable(number: 2, isOccupied: true),
    _CoffeeTable(number: 3, isOccupied: false),
    _CoffeeTable(number: 4, isOccupied: true),
    _CoffeeTable(number: 5, isOccupied: false),
    _CoffeeTable(number: 6, isOccupied: false),
    _CoffeeTable(number: 7, isOccupied: true),
    _CoffeeTable(number: 8, isOccupied: false),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? KedaiKopiViewModel();
    _viewModel.init();
    _viewModel.startAutoRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _viewModel.selectedTableNumber == null) {
        _showTableSelection();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.stopAutoRefresh();
    _searchController.dispose();
    super.dispose();
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

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _showTableSelection() async {
    final selectedTable = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final currentSelected = _viewModel.selectedTableNumber;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pilih Nomor Meja',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pilih meja yang kosong untuk menikmati pesanan di kedai.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildTableLegend(
                      color: AppColors.accentGreen,
                      label: 'Kosong',
                    ),
                    _buildTableLegend(
                      color: const Color(0xFFE5E7EB),
                      label: 'Terisi',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tables.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final table = _tables[index];
                    final isSelected = table.number == currentSelected;
                    final isAvailable = !table.isOccupied;
                    final color = isSelected
                        ? AppColors.maroon
                        : isAvailable
                            ? AppColors.accentGreen
                            : const Color(0xFFE5E7EB);

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: isAvailable
                          ? () => Navigator.pop(context, table.number)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(
                              alpha: isAvailable || isSelected ? 0.12 : 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: color, width: isSelected ? 2 : 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant_outlined,
                              color: isAvailable || isSelected
                                  ? color
                                  : AppColors.greyText,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Meja ${table.number.toString().padLeft(2, '0')}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAvailable || isSelected
                                    ? color
                                    : AppColors.greyText,
                              ),
                            ),
                            Text(
                              isAvailable ? 'Kosong' : 'Terisi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: isAvailable || isSelected
                                    ? color
                                    : AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedTable != null && mounted) {
      _viewModel.selectTable(selectedTable);
    }
  }

  Widget _buildTableLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: AppColors.greyText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        return Scaffold(
          backgroundColor: AppColors.bgCanvas,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
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
                                icon: const Icon(Icons.search_rounded,
                                    color: AppColors.darkText),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.darkText),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 4),
                              const UserAvatarWidget(radius: 13),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Card pemilihan meja
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _showTableSelection,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.chair_alt_rounded,
                                      color: AppColors.maroon, size: 20),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        vm.selectedTableNumber == null
                                            ? 'Pilih nomor meja'
                                            : 'Meja No. ${vm.selectedTableNumber.toString().padLeft(2, '0')}',
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
                              Row(
                                children: [
                                  Text(
                                    vm.selectedTableNumber == null
                                        ? 'Lihat meja'
                                        : 'Ganti meja',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppColors.maroon, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _viewModel.updateSearch,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search_rounded,
                                color: AppColors.greyText, size: 20),
                            hintText: 'Cari menu kopi atau camilan...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.greyText,
                            ),
                            border: InputBorder.none,
                            suffixIcon: vm.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: AppColors.greyText, size: 18),
                                    splashRadius: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _searchController.clear();
                                      _viewModel.clearSearch();
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
                        itemCount: vm.categories.length,
                        itemBuilder: (context, index) {
                          final isSelected =
                              vm.selectedCategoryIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(vm.categories[index]),
                              selected: isSelected,
                              onSelected: (_) =>
                                  _viewModel.selectCategory(index),
                              selectedColor: AppColors.maroon,
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.darkText,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.maroon
                                      : AppColors.lightBorder,
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
                      child: vm.isLoading && vm.allMenuList.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.maroon),
                            )
                          : RefreshIndicator(
                              onRefresh: _viewModel.fetchMenus,
                              color: AppColors.maroon,
                              child: vm.filteredMenuList.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 48),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: AppColors.cardBg,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: AppColors
                                                          .lightBorder),
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
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.darkText,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                vm.searchQuery.isNotEmpty
                                                    ? 'Menu dengan kata kunci "${vm.searchQuery}" tidak ditemukan. Coba kata kunci lain.'
                                                    : 'Tidak ada menu pada kategori ini.',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts
                                                    .plusJakartaSans(
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
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                              parent:
                                                  BouncingScrollPhysics()),
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20, bottom: 90),
                                      itemCount: vm.filteredMenuList.length,
                                      itemBuilder: (context, index) {
                                        final menu =
                                            vm.filteredMenuList[index];
                                        return MenuItemCard(
                                          name: menu.name,
                                          price: menu.price,
                                          image: menu.image,
                                          imageColor: _colorForCategory(
                                              menu.category),
                                          count: vm.itemCounts[menu.name] ?? 0,
                                          isAvailable: menu.isAvailable,
                                          onAdd: () => _viewModel.addToCart(menu),
                                          onRemove: () => _viewModel
                                              .decrementItem(menu.name),
                                        );
                                      },
                                    ),
                            ),
                    ),
                  ],
                ),

                // Floating Bottom Bar untuk BAYAR
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    offset: vm.totalItems > 0
                        ? Offset.zero
                        : const Offset(0, 1.5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: vm.totalItems > 0 ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: vm.totalItems == 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (vm.selectedTableNumber == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Silakan pilih meja yang kosong terlebih dahulu.'),
                                    action: SnackBarAction(
                                      label: 'PILIH MEJA',
                                      onPressed: _showTableSelection,
                                    ),
                                  ),
                                );
                                return;
                              }

                              final cartItems = _viewModel.cartItems;
                              if (cartItems.isEmpty) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PesananMejaView(
                                    cartItems: cartItems,
                                    tableName:
                                        'Meja No. ${vm.selectedTableNumber.toString().padLeft(2, '0')}',
                                    orderNumber:
                                        '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 12)}',
                                    viewModel: _viewModel,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.maroon,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.maroon
                                        .withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${vm.totalItems} Item • ${vm.selectedTableNumber == null ? 'Pilih meja' : 'Meja ${vm.selectedTableNumber.toString().padLeft(2, '0')}'}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatRupiah(vm.totalPrice),
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
                                      const Icon(Icons.chevron_right_rounded,
                                          color: Colors.white, size: 20),
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
      },
    );
  }
}
