import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/profil/models/profil_model.dart';

/// Kontrak repositori untuk fitur profil pengguna dan pusat bantuan.
abstract class ProfilRepository {
  Future<UserProfileModel> getUserProfile();
  Future<void> updateProfile({
    required String name,
    String? email,
    String? photoUrl,
  });
  Future<void> logout();
  List<FaqItemModel> getFaqList();
  NotificationPreferencesModel getNotificationPreferences();
  Future<void> saveNotificationPreferences(
      NotificationPreferencesModel preferences);
  Future<void> changePassword({
    required String newPassword,
  });
}

/// Implementasi [ProfilRepository] yang berinteraksi dengan [UserSession] dan penyimpanan lokal.
class ProfilRepositoryImpl implements ProfilRepository {
  NotificationPreferencesModel _preferences =
      const NotificationPreferencesModel();

  @override
  Future<UserProfileModel> getUserProfile() async {
    final session = UserSession.instance;
    if (!session.isInitialized) {
      await session.init();
    }
    return UserProfileModel(
      name: session.name,
      email: session.email,
      initials: session.initials,
      photoUrl: session.photoUrl,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    String? email,
    String? photoUrl,
  }) async {
    await UserSession.instance.updateUser(
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> logout() async {
    await UserSession.instance.clearSession();
  }

  @override
  List<FaqItemModel> getFaqList() {
    return const [
      FaqItemModel(
        question: 'Bagaimana cara meminjam buku fisik di Salon Pustaka?',
        answer:
            'Tunjukkan kartu anggota pustaka digital di tab Profil kepada pustakawan di Meja Sirkulasi Lt. 1. Anggota terdaftar dapat meminjam hingga 2 buku fisik sekaligus dengan masa pinjam 14 hari kalender.',
      ),
      FaqItemModel(
        question:
            'Apakah naskah kuno & e-faksimili langka dapat dibawa pulang?',
        answer:
            'Naskah kuno berstatus cagar budaya dan e-faksimili langka hanya dapat diteliti di Ruang Preservasi Lt. 2 Rumah Budaya Ratna dengan perlengkapan sarung tangan yang disediakan pengelola.',
      ),
      FaqItemModel(
        question: 'Bagaimana cara mendaftar agenda lokakarya budaya?',
        answer:
            'Buka tab "Agenda", pilih lokakarya yang diinginkan, pilih jenis tiket (Presale/Reguler), dan selesaikan transaksi melalui instruksi QRIS Nasional atau Virtual Account.',
      ),
      FaqItemModel(
        question: 'Berapa jam operasional Pustaka & Kedai Kopi Ratna?',
        answer:
            'Selasa s/d Minggu beroperasi pukul 09.00 - 21.00 WIB. Hari Senin tutup berkala untuk konservasi, restorasi buku kuno, dan pemeliharaan fasilitas salon.',
      ),
      FaqItemModel(
        question: 'Bagaimana mekanisme donasi buku atau manuskrip keluarga?',
        answer:
            'Kami menyambut kurasi naskah budaya dan buku sejarah lokal. Silakan kirimkan foto naskah beserta deskripsi singkat melalui WhatsApp kurator untuk jadwal temu telaah kuratorial.',
      ),
    ];
  }

  @override
  NotificationPreferencesModel getNotificationPreferences() {
    return _preferences;
  }

  @override
  Future<void> saveNotificationPreferences(
      NotificationPreferencesModel preferences) async {
    _preferences = preferences;
  }

  @override
  Future<void> changePassword({
    required String newPassword,
  }) async {
    // Simulasi pembaruan kata sandi akun
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
