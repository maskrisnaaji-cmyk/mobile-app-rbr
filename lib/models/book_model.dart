class Book {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String status; // Contoh: 'Tersedia di Rak', 'Dipinjam'
  final String shelfLocation; // Contoh: 'RAK 3A', 'RAK 2C'
  final String category;
  final String year;
  final String pageCount;
  final String language;
  final String condition;
  final String synopsis;
  final double rating;
  final int reviewCount;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.status,
    required this.shelfLocation,
    required this.category,
    required this.year,
    required this.pageCount,
    required this.language,
    required this.condition,
    required this.synopsis,
    required this.rating,
    required this.reviewCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] != null ? json['id'].toString() : '',
      title: json['title'] ?? json['tittle'] ?? 'Judul Buku',
      author: json['author'] ?? 'Penulis',
      coverImage: json['cover_image'] ?? json['coverImage'] ?? '',
      status: json['status'] ?? 'Tersedia di Rak',
      shelfLocation: json['shelfLocation'] ?? json['rack_location'] ?? json['rackLocation'] ?? 'RAK 1A',
      category: json['category'] ?? 'Umum',
      year: json['year'] != null ? json['year'].toString() : '2024',
      pageCount: json['pageCount'] != null ? json['pageCount'].toString() : (json['page_count'] != null ? json['page_count'].toString() : '150'),
      language: json['language'] ?? 'IDN',
      condition: json['condition'] ?? 'Baik',
      synopsis: json['synopsis'] ?? '',
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString()) ?? 4.8) : 4.8,
      reviewCount: json['reviewCount'] != null ? (int.tryParse(json['reviewCount'].toString()) ?? 50) : (json['review_count'] != null ? (int.tryParse(json['review_count'].toString()) ?? 50) : 50),
    );
  }

  static List<Book> get dummyBooks => [
        Book(
          id: '1',
          title: 'Dokumen Jibril',
          author: 'W.S. Rendra',
          coverImage: 'assets/images/dokumen_jibril.jpg',
          status: 'Tersedia di Rak',
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
        ),
        Book(
          id: '2',
          title: 'Anjing-Anjing Menyerbu Lek Zul',
          author: 'C.R. Tanujaya',
          coverImage: 'assets/images/anjing_anjing_menyerbu_lek_zul.jpg',
          status: 'Dipinjam',
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
          status: 'Tersedia di Rak',
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
          status: 'Tersedia di Rak',
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
