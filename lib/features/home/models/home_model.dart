import 'package:flutter/material.dart';

/// Model data buku populer yang ditampilkan pada Beranda
class HomePopularBook {
  final String title;
  final String author;
  final String shelf;
  final Color coverColor;
  final String? image;

  const HomePopularBook({
    required this.title,
    required this.author,
    required this.shelf,
    required this.coverColor,
    this.image,
  });
}

/// Model data agenda kegiatan terdekat pada Beranda
class HomeUpcomingAgenda {
  final String day;
  final String date;
  final String month;
  final String timeLocation;
  final String title;

  const HomeUpcomingAgenda({
    required this.day,
    required this.date,
    required this.month,
    required this.timeLocation,
    required this.title,
  });
}

/// Model data banner cagar budaya utama
class HomeBannerData {
  final String tag;
  final String title;
  final String description;
  final String imageAsset;

  const HomeBannerData({
    required this.tag,
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}
