import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class MenuItemCard extends StatelessWidget {
  final String name;
  final int price;
  final Color imageColor;
  final String? image;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageColor,
    this.image,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get _resolvedImage {
    if (image != null && image!.trim().isNotEmpty) {
      final img = image!.trim();
      // Cloud URL Vercel Blob / Full URL
      if (img.startsWith('http://') || img.startsWith('https://')) {
        return img;
      }
      var clean = img;
      if (clean.startsWith('/')) {
        clean = clean.substring(1);
      }
      if (clean.startsWith('assets/') && !clean.startsWith('assets/images/')) {
        clean = clean.replaceFirst('assets/', 'assets/images/');
      } else if (!clean.startsWith('assets/images/')) {
        clean = 'assets/images/$clean';
      }
      return clean;
    }

    // Fallback otomatis berdasarkan nama menu jika image kosong
    final n = name.toLowerCase();
    if (n.contains('pisang')) return 'assets/images/pisang_goreng_keju.jpg';
    if (n.contains('wedang') || n.contains('uwuh')) return 'assets/images/wedang_uwuh.jpg';
    if (n.contains('susu')) return 'assets/images/kopi_susu.jpg';
    if (n.contains('tubruk')) return 'assets/images/kopi_tubruk.jpg';
    if (n.contains('americano') || n.contains('v60')) return 'assets/images/americano.jpg';
    return '';
  }

  Widget _buildColorPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: imageColor,
      child: const Center(
        child: Icon(Icons.coffee_rounded, color: Colors.white70, size: 24),
      ),
    );
  }

  Widget _buildFallbackImage() {
    final n = name.toLowerCase();
    String? fallbackAsset;
    if (n.contains('pisang')) {
      fallbackAsset = 'assets/images/pisang_goreng_keju.jpg';
    } else if (n.contains('wedang') || n.contains('uwuh')) {
      fallbackAsset = 'assets/images/wedang_uwuh.jpg';
    } else if (n.contains('susu')) {
      fallbackAsset = 'assets/images/kopi_susu.jpg';
    } else if (n.contains('tubruk')) {
      fallbackAsset = 'assets/images/kopi_tubruk.jpg';
    } else if (n.contains('americano') || n.contains('v60')) {
      fallbackAsset = 'assets/images/americano.jpg';
    }

    if (fallbackAsset != null && fallbackAsset != _resolvedImage) {
      return Image.asset(
        fallbackAsset,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildColorPlaceholder(),
      );
    }
    return _buildColorPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveImage = _resolvedImage;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: effectiveImage.isNotEmpty
                  ? (effectiveImage.startsWith('http://') || effectiveImage.startsWith('https://')
                      ? Image.network(
                          effectiveImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                        )
                      : Image.asset(
                          effectiveImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                        ))
                  : _buildFallbackImage(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(price),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
              ],
            ),
          ),
          if (count == 0)
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                '+ Tambah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else
            Row(
              children: [
                InkWell(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, size: 16, color: AppColors.darkText),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$count',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.maroon,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
