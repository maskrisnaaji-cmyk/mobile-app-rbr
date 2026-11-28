class Book {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String status; // Default: 'TERSEDIA', berubah dinamis saat dipinjam ('DIPINJAM' / 'DISEWAKAN')
  final String shelfLocation; // Contoh: 'RAK 3A', 'RAK 2C'
  final String category;
  final String year;
  final String pageCount;
  final String language;
  final String condition;
  final String synopsis;
  final double rating;
  final int reviewCount;
  final String? digitalUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    this.status = 'TERSEDIA',
    required this.shelfLocation,
    required this.category,
    required this.year,
    required this.pageCount,
    required this.language,
    required this.condition,
    required this.synopsis,
    required this.rating,
    required this.reviewCount,
    this.digitalUrl,
  });

  String get image => coverImage;
  String get imageUrl => coverImage;

  bool get isAvailable =>
      status.toUpperCase() == 'TERSEDIA' ||
      status.toLowerCase().contains('tersedia');

  bool get isBorrowed =>
      status.toUpperCase() == 'DIPINJAM' ||
      status.toUpperCase() == 'DISEWAKAN' ||
      status.toLowerCase().contains('pinjam') ||
      status.toLowerCase().contains('sewa');

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverImage,
    String? status,
    String? shelfLocation,
    String? category,
    String? year,
    String? pageCount,
    String? language,
    String? condition,
    String? synopsis,
    double? rating,
    int? reviewCount,
    String? digitalUrl,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImage: coverImage ?? this.coverImage,
      status: status ?? this.status,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      category: category ?? this.category,
      year: year ?? this.year,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      condition: condition ?? this.condition,
      synopsis: synopsis ?? this.synopsis,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      digitalUrl: digitalUrl ?? this.digitalUrl,
    );
  }

  /// Helper untuk memastikan URL/path cover buku terpetakan dengan benar (Vercel Blob / Cloud URL / Local Asset)
  static String resolveCoverImageUrl(dynamic rawImage, {String title = ''}) {
    String img = rawImage?.toString().trim() ?? '';

    // URL Cloud (Vercel Blob / HTTPS / HTTP)
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return img;
    }

    // Fallback otomatis jika kosong berdasarkan judul buku
    if (img.isEmpty) {
      final t = title.toLowerCase();
      if (t.contains('jibril')) return 'assets/images/dokumen_jibril.jpg';
      if (t.contains('anjing') || t.contains('lek')) {
        return 'assets/images/anjing_anjing_menyerbu_lek_zul.jpg';
      }
      if (t.contains('peri')) {
        return 'assets/images/laki_laki_yang_kawin_dengan_peri.jpg';
      }
      if (t.contains('lipstik') || t.contains('tejo')) {
        return 'assets/images/lipstik_di_tas_doni.jpg';
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

  factory Book.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? json['tittle'] ?? 'Judul Buku';
    final rawCover = json['cover_image'] ??
        json['coverImage'] ??
        json['image'] ??
        json['imageUrl'] ??
        json['image_url'];
    final cover = resolveCoverImageUrl(rawCover, title: title);

    final rawStatus = (json['status'] ?? json['book_status'])?.toString().trim();
    final isAvail = rawStatus == null ||
        rawStatus.isEmpty ||
        rawStatus.toUpperCase() == 'TERSEDIA' ||
        rawStatus.toLowerCase().contains('tersedia');
    final parsedStatus = isAvail ? 'TERSEDIA' : 'DIPINJAM';

    return Book(
      id: (json['code'] ?? json['book_code'] ?? json['id'])?.toString() ?? '',
      title: title,
      author: json['author'] ?? 'Penulis',
      coverImage: cover,
      status: parsedStatus,
      shelfLocation: json['shelfLocation'] ??
          json['rack_location'] ??
          json['rackLocation'] ??
          'RAK 1A',
      category: json['category'] ?? 'Umum',
      year: json['year'] != null ? json['year'].toString() : '2024',
      pageCount: json['pageCount'] != null
          ? json['pageCount'].toString()
          : (json['page_count'] != null
              ? json['page_count'].toString()
              : '150'),
      language: json['language'] ?? 'IDN',
      condition: json['condition'] ?? 'Baik',
      synopsis: json['synopsis'] ?? '',
      rating: json['rating'] != null
          ? (double.tryParse(json['rating'].toString()) ?? 4.8)
          : 4.8,
      reviewCount: json['reviewCount'] != null
          ? (int.tryParse(json['reviewCount'].toString()) ?? 50)
          : (json['review_count'] != null
              ? (int.tryParse(json['review_count'].toString()) ?? 50)
              : 50),
      digitalUrl: (json['digital_url'] ?? json['digitalUrl'])?.toString().trim().isNotEmpty == true
          ? (json['digital_url'] ?? json['digitalUrl']).toString().trim()
          : null,
    );
  }

  static List<Book> get dummyBooks => [
        Book(
          id: '1',
          title: 'Dokumen Jibril',
          author: 'W.S. Rendra',
          coverImage: 'assets/images/dokumen_jibril.jpg',
          status: 'TERSEDIA',
          shelfLocation: 'RAK 3A',
          category: 'KOLEKSI KHUSUS SASTRA KLASIK',
          year: '1978',
          pageCount: '124',
          language: 'IDN',
          condition: 'Arsip Terawat',
          synopsis:
              'Naskah "Dokumen Jibril" merupakan salah satu karya monumental W.S. Rendra yang merekam dialektika batin kemanusiaan, kritik sosial yang tajam, serta pergolakan spiritual di era 70-an. Dengan gaya puitik yang kuat dan metafora yang berani, Rendra menghadirkan perenungan mendalam mengenai keadilan, integritas moral, dan suara nurani rakyat. Dokumen ini menjadi rujukan vital bagi telaah sastra perlawanan dan estetika panggung Bengkel Teater di Yogyakarta.',
          rating: 4.9,
          reviewCount: 128,
          digitalUrl: 'https://archive.org/details/dokumen-jibril',
        ),
        Book(
          id: '2',
          title: 'Anjing-Anjing Menyerbu Lek Zul',
          author: 'C.R. Tanujaya',
          coverImage: 'assets/images/anjing_anjing_menyerbu_lek_zul.jpg',
          status: 'TERSEDIA',
          shelfLocation: 'RAK 3B',
          category: 'PROSA KONTEMPORER',
          year: '1984',
          pageCount: '210',
          language: 'IDN',
          condition: 'Baik',
          synopsis:
              'Sebuah narasi satir mengenai dinamika sosial masyarakat desa yang menghadapi benturan modernitas dan intrik kuasa. Kisah Lek Zai merefleksikan kegelisahan warga pinggiran dalam mempertahankan tanah dan martabat hidup di tengah desakan arus pembangunan industri baru.',
          rating: 4.7,
          reviewCount: 86,
        ),
        Book(
          id: '3',
          title: 'Laki-Laki Yang Kawin Dengan Peri',
          author: 'Eka Kurniawan',
          coverImage: 'assets/images/laki_laki_yang_kawin_dengan_peri.jpg',
          status: 'TERSEDIA',
          shelfLocation: 'RAK 2C',
          category: 'SASTRA REALISME MAGIS',
          year: '2015',
          pageCount: '188',
          language: 'IDN',
          condition: 'Sangat Baik',
          synopsis:
              'Kumpulan cerita pendek yang meramu realisme magis, mitos lokal nusantara, humor gelap, dan kepedihan hidup sehari-hari. Eka Kurniawan membawa pembaca menjelajahi batas kabur antara kenyataan dan dongeng dalam balutan bahasa yang lugas dan memikat nurani pembaca.',
          rating: 4.8,
          reviewCount: 142,
        ),
        Book(
          id: '4',
          title: 'Lipstik Di Tas Doni',
          author: 'Sujiwo Tejo',
          coverImage: 'assets/images/lipstik_di_tas_doni.jpg',
          status: 'TERSEDIA',
          shelfLocation: 'RAK 1A',
          category: 'KOLOM & ESAI BUDAYA',
          year: '2007',
          pageCount: '156',
          language: 'IDN',
          condition: 'Terawat',
          synopsis:
              'Kumpulan esai reflektif dan celoteh khas sang Dalang Wayang dan Budayawan yang membongkar kemunafikan sosial, cinta, filsafat wayang, dan spiritualitas urban dengan gaya santai namun sarat perenungan tajam mengenai kemanusiaan.',
          rating: 4.6,
          reviewCount: 95,
        ),
      ];
}
