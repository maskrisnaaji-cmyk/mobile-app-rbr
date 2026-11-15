class EventModel {
  final dynamic id;
  final String title;
  final String category;
  final String date;
  final DateTime? dateTime;
  final String time;
  final String location;
  final int price;
  final double priceDouble;
  final String formattedPrice;
  final int quota;
  final int sold;
  final int remainingSeats;
  final String seats;
  final String status;
  final String image;
  final String bannerImage;
  final String? imageFallback;

  EventModel({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    this.dateTime,
    required this.time,
    required this.location,
    required this.price,
    double? priceDouble,
    String? formattedPrice,
    required this.quota,
    required this.sold,
    int? remainingSeats,
    String? seats,
    this.status = 'Aktif',
    required this.image,
    String? bannerImage,
    this.imageFallback,
  })  : priceDouble = priceDouble ?? price.toDouble(),
        formattedPrice = formattedPrice ?? formatRupiah(price),
        remainingSeats = remainingSeats ?? (quota - sold),
        seats = seats ??
            (sold >= quota ? 'Tiket Penuh' : 'Sisa ${quota - sold} Kursi'),
        bannerImage = bannerImage ?? image;

  /// Format angka integer ke representasi Rupiah (atau 'Gratis' jika 0)
  static String formatRupiah(int price) {
    if (price <= 0) return 'Gratis';
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  /// Parser harga fleksibel dari JSON key 'price' backend
  static int parsePrice(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();

    final str = raw.toString().trim();
    if (str.isEmpty ||
        str.toLowerCase() == 'gratis' ||
        str.toLowerCase() == 'free') {
      return 0;
    }

    if (str.contains('.')) {
      final parts = str.split('.');
      if (parts.length == 2 && parts[1].length == 3 && !str.contains(',')) {
        final clean = str.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(clean) ?? 0;
      }
      final clean = str.replaceAll(RegExp(r'[^0-9.]'), '');
      final d = double.tryParse(clean);
      if (d != null) return d.toInt();
    }

    final digits = str.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  /// Parser tanggal fleksibel (ISO YYYY-MM-DD atau format bahasa Indonesia)
  /// Parser tanggal aman menggunakan DateTime.parse() dengan penanganan error dan fallback
  static DateTime? parseDate(dynamic rawDate) {
    if (rawDate == null) return null;
    final dateStr = rawDate.toString().trim();
    if (dateStr.isEmpty) return null;

    // 1. Coba DateTime.parse() standar ISO YYYY-MM-DD
    try {
      final parsed = DateTime.parse(dateStr);
      // Cegah bug tahun 1899 atau tahun tidak wajar
      if (parsed.year >= 2000 && parsed.year <= 2100) {
        return parsed;
      }
    } catch (_) {}

    // 2. Coba DateTime.tryParse()
    try {
      final iso = DateTime.tryParse(dateStr);
      if (iso != null && iso.year >= 2000 && iso.year <= 2100) {
        return iso;
      }
    } catch (_) {}

    // 3. Fallback teks Indonesia (contoh: "Sabtu, 28 September 2026")
    final clean = dateStr.toLowerCase();
    final monthMap = {
      'januari': 1, 'februari': 2, 'maret': 3, 'april': 4,
      'mei': 5, 'juni': 6, 'juli': 7, 'agustus': 8,
      'september': 9, 'oktober': 10, 'november': 11, 'desember': 12,
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
      'jun': 6, 'jul': 7, 'agu': 8, 'agust': 8,
      'sep': 9, 'okt': 10, 'nov': 11, 'des': 12,
    };

    final reg = RegExp(r'(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})');
    final match = reg.firstMatch(clean);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final monthName = match.group(2)!;
      final year = int.tryParse(match.group(3)!);
      final month = monthMap[monthName];
      if (day != null && month != null && year != null) {
        if (year >= 2000 && year <= 2100) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  /// Parser gambar banner agenda (mendukung Cloud URL Vercel Blob, path aset, serta alias banner_image)
  static String resolveEventImage(
    dynamic rawImage,
    dynamic rawBannerImage, {
    String title = '',
    DateTime? eventDate,
  }) {
    String img = '';
    // Utamakan banner_image lalu image
    if (rawBannerImage != null && rawBannerImage.toString().trim().isNotEmpty) {
      img = rawBannerImage.toString().trim();
    } else if (rawImage != null && rawImage.toString().trim().isNotEmpty) {
      img = rawImage.toString().trim();
    }

    // Jika berupa Cloud URL langsung (Vercel Blob / HTTPS)
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return img;
    }

    // Cek judul acara untuk aset lokal yang tersedia di assets/images/
    final normalizedTitle = title.toLowerCase();
    if (normalizedTitle.contains('napak tanah')) {
      return 'assets/images/napak_tanah.png';
    }
    if (normalizedTitle.contains('teater') ||
        normalizedTitle.contains('rungkad') ||
        normalizedTitle.contains('pak rungkad')) {
      return 'assets/images/teather_rungkad.png';
    }
    if (normalizedTitle.contains('obrolan') ||
        normalizedTitle.contains('kearifan')) {
      return 'assets/images/oktober_08_obrolan_budaya.jpg';
    }
    if (normalizedTitle.contains('batik')) {
      return 'assets/images/oktober_09_pameran_batik.jpg';
    }
    if (normalizedTitle.contains('keramik')) {
      return 'assets/images/oktober_11_workshop_keramik.jpg';
    }
    if (normalizedTitle.contains('akustik') ||
        normalizedTitle.contains('puisi')) {
      return 'assets/images/oktober_12_malam_akustik.jpg';
    }
    if (normalizedTitle.contains('sabtu budaya') ||
        normalizedTitle.contains('gotong royong')) {
      return 'assets/images/oktober_13_sabtu_budaya.jpg';
    }

    // Penyesuaian tanggal event Oktober 2026
    if (eventDate?.year == 2026 && eventDate?.month == 10) {
      switch (eventDate!.day) {
        case 8:
          return 'assets/images/oktober_08_obrolan_budaya.jpg';
        case 9:
          return 'assets/images/oktober_09_pameran_batik.jpg';
        case 11:
          return 'assets/images/oktober_11_workshop_keramik.jpg';
        case 12:
          return 'assets/images/oktober_12_malam_akustik.jpg';
        case 13:
          return 'assets/images/oktober_13_sabtu_budaya.jpg';
      }
    }

    // Resolusi path gambar backend ke path aset Flutter
    if (img.isNotEmpty) {
      var clean = img;
      if (clean.startsWith('/')) {
        clean = clean.substring(1);
      }
      if (clean.contains('napak_tanah')) return 'assets/images/napak_tanah.png';
      if (clean.contains('rungkad')) return 'assets/images/teather_rungkad.png';

      if (clean.startsWith('assets/') && !clean.startsWith('assets/images/')) {
        clean = clean.replaceFirst('assets/', 'assets/images/');
      } else if (!clean.startsWith('assets/images/')) {
        clean = 'assets/images/$clean';
      }
      return clean;
    }

    return '';
  }

  /// Fallback gambar alternatif jika file utama gagal dibuka
  static String? resolveImageFallback(String title) {
    final normalizedTitle = title.toLowerCase();
    if (normalizedTitle.contains('napak tanah')) {
      return 'assets/images/napak_tanah.png';
    }
    if (normalizedTitle.contains('teater') ||
        normalizedTitle.contains('rungkad') ||
        normalizedTitle.contains('pak rungkad')) {
      return 'assets/images/teather_rungkad.png';
    }
    return null;
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString() ??
        json['tittle']?.toString() ??
        'Acara Budaya';
    final category = (json['category'] != null && json['category'].toString().trim().isNotEmpty) ? json['category'].toString().trim() : (json['kategori']?.toString().trim() ?? 'Budaya');
    final rawDate = json['date']?.toString() ?? '';
    final parsedDate = parseDate(rawDate);
    final time = json['time']?.toString() ?? '15:00 WIB';
    final location = json['location']?.toString() ?? 'Pendopo Utama RBR';

    // Memetakan field price secara akurat (tidak otomatis tertulis "Gratis" jika > 0)
    final priceInt = parsePrice(json['price'] ?? json['harga']);
    final priceDbl = priceInt.toDouble();
    final formatted = formatRupiah(priceInt);

    final quota = int.tryParse(json['quota']?.toString() ?? '') ?? 50;
    final sold = int.tryParse(json['sold']?.toString() ?? '') ?? 0;
    final status = json['status']?.toString() ?? 'Aktif';

    // Memetakan field image dan banner_image
    final rawImage = json['image'];
    final rawBanner = json['banner_image'] ?? json['bannerImage'];
    final resolvedImage = resolveEventImage(
      rawImage,
      rawBanner,
      title: title,
      eventDate: parsedDate,
    );
    final fallback = resolveImageFallback(title);

    return EventModel(
      id: json['id'],
      title: title,
      category: category,
      date: rawDate,
      dateTime: parsedDate,
      time: time,
      location: location,
      price: priceInt,
      priceDouble: priceDbl,
      formattedPrice: formatted,
      quota: quota,
      sold: sold,
      status: status,
      image: resolvedImage,
      bannerImage: resolvedImage,
      imageFallback: fallback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'time': time,
      'location': location,
      'price': price,
      'quota': quota,
      'sold': sold,
      'status': status,
      'image': image,
      'banner_image': bannerImage,
    };
  }
}

