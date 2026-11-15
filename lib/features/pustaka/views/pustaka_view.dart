import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/features/pustaka/viewmodels/pustaka_viewmodel.dart';
import 'package:mobile_app/features/pustaka/widgets/book_card_grid_item.dart';
import 'package:mobile_app/features/pustaka/widgets/librarian_help_banner.dart';
import 'package:mobile_app/features/pustaka/widgets/pustaka_filter_chip.dart';

class PustakaView extends StatefulWidget {
  final PustakaViewModel? viewModel;

  const PustakaView({super.key, this.viewModel});

  @override
  State<PustakaView> createState() => _PustakaViewState();
}

class _PustakaViewState extends State<PustakaView> {
  late final PustakaViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? PustakaViewModel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final filteredBooks = _viewModel.filteredBooks;

        return RefreshIndicator(
          onRefresh: _viewModel.fetchBooks,
          color: AppColors.maroon,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.maroon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pustaka Ratna',
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _searchFocusNode.requestFocus(),
                          icon: const Icon(Icons.search, color: AppColors.textMain),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none, color: AppColors.textMain),
                        ),
                        const SizedBox(width: 4),
                        const UserAvatarWidget(radius: 13),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  'Katalog Pustaka',
                  style: GoogleFonts.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  'Koleksi naskah, sastra, & sejarah Nusantara',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
                if (_viewModel.isLoading) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    color: AppColors.maroon,
                    backgroundColor: AppColors.border,
                    minHeight: 2,
                  ),
                ],
                const SizedBox(height: 12),

                // Search Field
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) => _viewModel.filterBooks(value),
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari judul buku, pengarang, naskah...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _viewModel.filterBooks('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
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
                const SizedBox(height: 16),

                // Grid Koleksi Buku
                if (filteredBooks.isEmpty && !_viewModel.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Buku tidak ditemukan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                const SizedBox(height: 20),

                // Banner Bantuan Pustakawan
                const LibrarianHelpBanner(),
              ],
            ),
          ),
        );
      },
    );
  }
}
