import 'package:flutter/material.dart';

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

  const FavoriteBook({
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.rating,
    required this.shelf,
    required this.desc,
    required this.icon,
  });

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
