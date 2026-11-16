import 'package:flutter/material.dart';
import 'package:mobile_app/features/pustaka/models/book_model.dart';

/// Model data untuk koleksi buku & manuskrip favorit
class FavoriteBook {
  final String title;
  final String author;
  final String category;
  final String year;
  final double rating;
  final String shelf;
  final String desc;
  final IconData icon;
  final String? coverImage;
  final String? bookId;

  const FavoriteBook({
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.rating,
    required this.shelf,
    required this.desc,
    required this.icon,
    this.coverImage,
    this.bookId,
  });

  factory FavoriteBook.fromBook(Book book) {
    IconData resolvedIcon = Icons.menu_book_rounded;
    final cat = book.category.toLowerCase();
    if (cat.contains('drama') || cat.contains('teater')) {
      resolvedIcon = Icons.theater_comedy_rounded;
    } else if (cat.contains('sejarah') || cat.contains('arsip') || cat.contains('babad')) {
      resolvedIcon = Icons.history_edu_rounded;
    } else if (cat.contains('sastra') || cat.contains('prosa') || cat.contains('esai')) {
      resolvedIcon = Icons.auto_stories_rounded;
    }

    return FavoriteBook(
      title: book.title,
      author: book.author,
      category: book.category,
      year: book.year,
      rating: book.rating,
      shelf: book.shelfLocation,
      desc: book.synopsis.isNotEmpty
          ? book.synopsis
          : 'Koleksi naskah literasi budaya Rumah Budaya Ratna.',
      icon: resolvedIcon,
      coverImage: book.coverImage,
      bookId: book.id,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'category': category,
        'year': year,
        'rating': rating,
        'shelf': shelf,
        'desc': desc,
        'coverImage': coverImage,
        'bookId': bookId,
      };

  factory FavoriteBook.fromJson(Map<String, dynamic> json) {
    return FavoriteBook(
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Umum',
      year: json['year']?.toString() ?? '2024',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      shelf: json['shelf']?.toString() ?? 'RAK 1A',
      desc: json['desc']?.toString() ?? '',
      icon: Icons.menu_book_rounded,
      coverImage: json['coverImage']?.toString(),
      bookId: json['bookId']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteBook &&
          runtimeType == other.runtimeType &&
          (title.toLowerCase().trim() == other.title.toLowerCase().trim() ||
              (bookId != null && bookId == other.bookId));

  @override
  int get hashCode => title.toLowerCase().trim().hashCode;

  static List<FavoriteBook> get demoFavorites => const [
        FavoriteBook(
          title: 'Dokumen Jibril',
          author: 'W.S. Rendra',
          category: 'Naskah Drama',
          year: '1978',
          rating: 4.9,
          shelf: 'RAK 3A',
          desc: 'Naskah monumental dialektika moral dan kritik sosial tajam era 70-an Bengkel Teater.',
          icon: Icons.theater_comedy_rounded,
        ),
        FavoriteBook(
          title: 'LemahTulis: Babad Naskah',
          author: 'Arsip Koleksi Kuno Singhasari',
          category: 'Manuskrip & Arsip',
          year: '1820',
          rating: 5.0,
          shelf: 'RAK 1C',
          desc: 'Transkripsi tembang pupuh aksara Jawa Kuno mengenai kosmologi tanah Malang.',
          icon: Icons.menu_book_rounded,
        ),
        FavoriteBook(
          title: 'Anjing-Anjing Menyerbu Lek Zai',
          author: 'C.R. Tanujaya',
          category: 'Naskah Drama',
          year: '1984',
          rating: 4.7,
          shelf: 'RAK 3B',
          desc: 'Satir panggung pertarungan hak tanah masyarakat agraris dan modernisasi.',
          icon: Icons.theater_comedy_rounded,
        ),
        FavoriteBook(
          title: 'Laki-Laki Yang Kawin Dengan Peri',
          author: 'Eka Kurniawan',
          category: 'Prosa Budaya',
          year: '2015',
          rating: 4.8,
          shelf: 'RAK 2C',
          desc: 'Realisme magis yang meramu mitos nusantara, tragedi cinta, dan satir kehidupan.',
          icon: Icons.auto_stories_rounded,
        ),
        FavoriteBook(
          title: 'Serat Centhini: Faksimili Jilid IV',
          author: 'Tim Preservasi Kraton Surakarta',
          category: 'Manuskrip & Arsip',
          year: '1814',
          rating: 4.9,
          shelf: 'RAK 1B',
          desc: 'Ensiklopedia kebudayaan, spiritualitas, kuliner, dan tata laku tanah Jawa.',
          icon: Icons.menu_book_rounded,
        ),
        FavoriteBook(
          title: 'Alun-Alun Malang Tempo Doeloe',
          author: 'Dukut Imam Widodo',
          category: 'Prosa Budaya',
          year: '2004',
          rating: 4.8,
          shelf: 'RAK 1A',
          desc: 'Rekonstruksi visual sejarah tata ruang kota Malang pada era kolonial Hindia Belanda.',
          icon: Icons.history_edu_rounded,
        ),
      ];
}
