import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/booking_payment/views/booking_checkout_view.dart';

/// Komponen kartu item acara yang diekstrak dari halaman agenda
class AgendaCard extends StatelessWidget {
  final dynamic eventId;
  final String category;
  final String time;
  final String seats;
  final String location;
  final String title;
  final String price;
  final Color imageColor;
  final String? image;
  final String? imageFallback;
  final int? eventId;

  const AgendaCard({
    super.key,
    this.eventId,
    required this.category,
    required this.time,
    required this.seats,
    required this.location,
    required this.title,
    required this.price,
    required this.imageColor,
    this.image,
    this.imageFallback,
    this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null && image!.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    child: (image!.startsWith('http')
                        ? Image.network(
                            image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => imageFallback == null
                                ? Container(color: imageColor)
                                : Image.asset(
                                    imageFallback!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: imageColor),
                                  ),
                          )
                        : Image.asset(
                            image!.startsWith('/') ? image!.substring(1) : image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => imageFallback == null
                                ? Container(color: imageColor)
                                : Image.asset(
                                    imageFallback!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: imageColor),
                                  ),
                          )),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      category,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(time,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isSoldOut || seats.contains('Penuh'))
                          ? Colors.red.shade900
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSoldOut ? 'Tiket Penuh' : seats,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.maroon),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.lora(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biaya Partisipasi',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5, color: AppColors.textMuted)),
                        Text(
                          price,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.maroon),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingCheckoutView(
                              eventId: eventId,
                              eventTitle: title,
                              category: category,
                              time: time,
                              location: location,
                              basePrice: price,
                              eventImage: image,
                              eventImageFallback: imageFallback,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSoldOut
                            ? Colors.grey.shade400
                            : AppColors.maroon,
                        foregroundColor:
                            isSoldOut ? Colors.grey.shade600 : Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isSoldOut ? 'TIKET PENUH' : 'PESAN TIKET',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
