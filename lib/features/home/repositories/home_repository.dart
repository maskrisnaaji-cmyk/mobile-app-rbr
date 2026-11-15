import 'package:flutter/material.dart';
import 'package:mobile_app/features/home/models/home_model.dart';

/// Kontrak repository untuk konten Beranda & Beranda Ringkasan
abstract class HomeRepository {
  Future<List<HomePopularBook>> getPopularBooks();
  Future<HomeUpcomingAgenda> getUpcomingAgenda();
  Future<HomeBannerData> getBannerData();
  Future<String> getQuote();
}

/// Implementasi repository beranda
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<HomePopularBook>> getPopularBooks() async {
    return const [
      HomePopularBook(
        title: 'Dokumen Jibril',
        author: 'Eko Triono',
        shelf: 'Rak 2A',
        coverColor: Color(0xFF1F2421),
        image: 'assets/images/dokumen_jibril.jpg',
      ),
      HomePopularBook(
        title: 'Anjing-Anjing Menyerbu Lek Zul',
        author: 'C.R. Tanujaya',
        shelf: 'Rak 3B',
        coverColor: Color(0xFF1E3A5F),
        image: 'assets/images/anjing_anjing_menyerbu_lek_zul.jpg',
      ),
      HomePopularBook(
        title: 'Laki-Laki Peri',
        author: 'Eka Kurniawan',
        shelf: 'Rak 2C',
        coverColor: Color(0xFF513B41),
        image: 'assets/images/laki_laki_yang_kawin_dengan_peri.jpg',
      ),
    ];
  }

  @override
  Future<HomeUpcomingAgenda> getUpcomingAgenda() async {
    return const HomeUpcomingAgenda(
      day: 'SEN',
      date: '12',
      month: 'SEP',
      timeLocation: '19.00 WIB - Pendopo Utama',
      title: 'Malam Akustik & Puisi Nusantara',
    );
  }

  @override
  Future<HomeBannerData> getBannerData() async {
    return const HomeBannerData(
      tag: 'CAGAR BUDAYA & LITERASI',
      title: 'Rumah Budaya Ratna',
      description: 'Ruang temu seni, pemikiran, dan rasa di tengah kehangatan tradisi Jawa.',
      imageAsset: 'assets/images/rbr_frontt.jpg',
    );
  }

  @override
  Future<String> getQuote() async {
    return 'Membaca adalah merawat ingatan, berbudaya adalah merawat martabat.';
  }
}
