import 'package:google_sign_in/google_sign_in.dart';

/// Implementasi GoogleIdentity untuk menyimpan akun Google pengguna
class GoogleIdentityAccount implements GoogleIdentity {
  const GoogleIdentityAccount({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  final String id;

  @override
  final String email;

  @override
  final String? displayName;

  @override
  final String? photoUrl;
}

/// Model data pengguna terautentikasi (User Session)
class AuthUser {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? token;
  final String? photoUrl;
  final String? googleId;
  final Map<String, dynamic>? rawUser;

  const AuthUser({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.token,
    this.photoUrl,
    this.googleId,
    this.rawUser,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, {String? token}) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final String resolvedEmail = userMap['email']?.toString() ?? '';
    final String resolvedName = userMap['name']?.toString() ??
        userMap['username']?.toString() ??
        (resolvedEmail.contains('@') ? resolvedEmail.split('@')[0] : 'Pengguna');

    return AuthUser(
      id: userMap['id']?.toString(),
      name: resolvedName,
      email: resolvedEmail,
      phone: userMap['phone']?.toString(),
      token: token ?? json['token']?.toString(),
      photoUrl: userMap['photo_url']?.toString() ?? userMap['photoUrl']?.toString(),
      googleId: userMap['google_id']?.toString() ?? userMap['googleId']?.toString(),
      rawUser: userMap,
    );
  }
}

/// Model data hasil respons autentikasi
class AuthResponse {
  final bool success;
  final String message;
  final AuthUser? user;
  final String? token;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });
}
