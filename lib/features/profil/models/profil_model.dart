/// Model data representasi profil pengguna di Rumah Budaya Ratna.
class UserProfileModel {
  final String name;
  final String email;
  final String initials;
  final String? photoUrl;
  final String memberId;
  final int borrowedBooksCount;
  final int culturalAgendasCount;
  final int favoriteCollectionsCount;

  const UserProfileModel({
    required this.name,
    required this.email,
    required this.initials,
    this.photoUrl,
    this.memberId = 'RBR-2024-8842',
    this.borrowedBooksCount = 12,
    this.culturalAgendasCount = 8,
    this.favoriteCollectionsCount = 14,
  });

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? initials,
    String? photoUrl,
    String? memberId,
    int? borrowedBooksCount,
    int? culturalAgendasCount,
    int? favoriteCollectionsCount,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      photoUrl: photoUrl ?? this.photoUrl,
      memberId: memberId ?? this.memberId,
      borrowedBooksCount: borrowedBooksCount ?? this.borrowedBooksCount,
      culturalAgendasCount: culturalAgendasCount ?? this.culturalAgendasCount,
      favoriteCollectionsCount:
          favoriteCollectionsCount ?? this.favoriteCollectionsCount,
    );
  }
}

/// Model untuk pertanyaan yang sering diajukan (FAQ) pada pusat bantuan.
class FaqItemModel {
  final String question;
  final String answer;

  const FaqItemModel({
    required this.question,
    required this.answer,
  });
}

/// Model preferensi notifikasi dan privasi pengguna.
class NotificationPreferencesModel {
  final bool notifLoanDue;
  final bool notifWorkshopAgenda;
  final bool notifCuratorArticles;
  final bool notifWhatsapp;
  final bool publicReviewProfile;

  const NotificationPreferencesModel({
    this.notifLoanDue = true,
    this.notifWorkshopAgenda = true,
    this.notifCuratorArticles = true,
    this.notifWhatsapp = true,
    this.publicReviewProfile = false,
  });

  NotificationPreferencesModel copyWith({
    bool? notifLoanDue,
    bool? notifWorkshopAgenda,
    bool? notifCuratorArticles,
    bool? notifWhatsapp,
    bool? publicReviewProfile,
  }) {
    return NotificationPreferencesModel(
      notifLoanDue: notifLoanDue ?? this.notifLoanDue,
      notifWorkshopAgenda: notifWorkshopAgenda ?? this.notifWorkshopAgenda,
      notifCuratorArticles: notifCuratorArticles ?? this.notifCuratorArticles,
      notifWhatsapp: notifWhatsapp ?? this.notifWhatsapp,
      publicReviewProfile: publicReviewProfile ?? this.publicReviewProfile,
    );
  }
}
