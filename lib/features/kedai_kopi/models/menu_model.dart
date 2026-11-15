class MenuModel {
  final dynamic id;
  final String name;
  final String category;
  final int price;
  final double priceDouble;
  final String image;
  final String imageUrl;
  final String description;
  final String status;

  MenuModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    double? priceDouble,
    required this.image,
    String? imageUrl,
    this.description = '',
    this.status = 'Tersedia',
  })  : priceDouble = priceDouble ?? price.toDouble(),
        imageUrl = imageUrl ?? image;

  /// Helper untuk mem-parsing harga dari berbagai tipe data (int, double, string)
  /// agar tidak bernilai 0 jika data harga valid di backend.
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

    // Penanganan pemisah desimal atau ribuan
    if (str.contains('.')) {
      final parts = str.split('.');
      // Format ribuan Indonesia e.g. "18.000"
      if (parts.length == 2 && parts[1].length == 3 && !str.contains(',')) {
        final clean = str.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(clean) ?? 0;
      }
      // Format desimal e.g. "18000.00"
      final clean = str.replaceAll(RegExp(r'[^0-9.]'), '');
      final d = double.tryParse(clean);
      if (d != null) return d.toInt();
    }

    final digits = str.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  /// Helper untuk mengonversi harga ke tipe double
  static double parsePriceToDouble(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    return parsePrice(raw).toDouble();
  }

  /// Helper untuk memastikan URL/path aset dari backend terpetakan dengan benar
  static String resolveImageUrl(dynamic rawImage, {String name = ''}) {
    String img = rawImage?.toString().trim() ?? '';

    // URL Cloud (Vercel Blob / Full URL)
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return img;
    }

    // Fallback otomatis berdasarkan nama menu jika image kosong
    if (img.isEmpty) {
      final n = name.toLowerCase();
      if (n.contains('pisang')) return 'assets/images/pisang_goreng_keju.jpg';
      if (n.contains('wedang') || n.contains('uwuh')) {
        return 'assets/images/wedang_uwuh.jpg';
      }
      if (n.contains('susu')) return 'assets/images/kopi_susu.jpg';
      if (n.contains('tubruk')) return 'assets/images/kopi_tubruk.jpg';
      if (n.contains('americano') || n.contains('v60')) {
        return 'assets/images/americano.jpg';
      }
      return '';
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

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final category = (json['category'] != null && json['category'].toString().trim().isNotEmpty) ? json['category'].toString().trim() : (json['kategori']?.toString().trim() ?? 'Kopi Nusantara');

    // Memetakan key 'price' dari backend dan dikonversi ke int & double
    final rawPrice = json['price'] ?? json['harga'];
    final priceInt = parsePrice(rawPrice);
    final priceDbl = parsePriceToDouble(rawPrice);

    // Memetakan field image / imageUrl ke URL atau path aset yang valid
    final rawImg = json['image'] ?? json['imageUrl'] ?? json['image_url'];
    final resolvedImg = resolveImageUrl(rawImg, name: name);

    final description =
        json['description']?.toString() ?? json['note']?.toString() ?? '';
    final status = json['status']?.toString() ?? 'Tersedia';

    return MenuModel(
      id: json['id'],
      name: name,
      category: category,
      price: priceInt,
      priceDouble: priceDbl,
      image: resolvedImg,
      imageUrl: resolvedImg,
      description: description,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
    };
  }
}

