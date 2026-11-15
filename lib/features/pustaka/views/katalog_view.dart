import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/pustaka/viewmodels/pustaka_viewmodel.dart';
import 'package:mobile_app/features/pustaka/widgets/book_card_grid_item.dart';
import 'package:mobile_app/features/pustaka/widgets/pustaka_filter_chip.dart';

class KatalogView extends StatefulWidget {
  final PustakaViewModel? viewModel;

  const KatalogView({super.key, this.viewModel});

  @override
  State<KatalogView> createState() => _KatalogViewState();
}

class _KatalogViewState extends State<KatalogView> {
  late final PustakaViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? PustakaViewModel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final filteredBooks = _viewModel.filteredBooks;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F6F0),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textMain),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Katalog Pustaka',
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // Search & Filter header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => _viewModel.filterBooks(val),
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Cari judul buku, naskah, atau penulis...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        _viewModel.filterBooks('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _viewModel.categories.map((cat) {
                              return PustakaFilterChip(
                                label: cat,
                                isSelected: _viewModel.selectedCategory == cat,
                                onTap: () => _viewModel.selectCategory(cat),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Book Grid List
                  Expanded(
                    child: filteredBooks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.menu_book, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Tidak ada buku yang cocok',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              return BookCardGridItem(book: book);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
