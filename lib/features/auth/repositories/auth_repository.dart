import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/api_logger.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/auth/models/auth_user_model.dart';

/// Extension kompatibilitas GoogleSignIn untuk platform Web dan Mobile
extension GoogleSignInCompat on GoogleSignIn {
  Future<GoogleIdentity?> signIn() async {
    if (supportsAuthenticate()) {
      return await authenticate();
    }

    if (kIsWeb) {
      try {
        final authz = await authorizationClient.authorizeScopes([
          'email',
          'profile',
          'openid',
        ]);
        final token = authz.accessToken;
        if (token.isNotEmpty) {
          final res = await http.get(
            Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body) as Map<String, dynamic>;
            return GoogleIdentityAccount(
              id: data['sub']?.toString() ?? '',
              email: data['email']?.toString() ?? '',
              displayName: data['name']?.toString(),
              photoUrl: data['picture']?.toString(),
            );
          }
        }
      } catch (e) {
        debugPrint('[GoogleSignIn] Web authorizeScopes notice: $e');
      }
    }

    final future = attemptLightweightAuthentication();
    if (future != null) {
      return await future;
    }
    return null;
  }
}

/// Kontrak repository untuk autentikasi pengguna
abstract class AuthRepository {
  Future<void> initGoogleSignIn();
  Future<GoogleIdentity?> signInWithGoogleSdk();

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthResponse> processGoogleBackendLogin({
    required String email,
    String? name,
    String? photoUrl,
    String? googleId,
  });

  Future<void> forgotPassword(String identifier);
  Future<void> verifyResetAccount(String email, String phone);
  Future<void> resetPasswordDirect(String email, String phone, String newPassword);
}

/// Implementasi repository autentikasi terhubung ke REST API & Google Sign-In SDK
class AuthRepositoryImpl implements AuthRepository {
  final http.Client _client;
  static bool _isGoogleSignInInitialized = false;
  static Future<void>? _googleSignInInitFuture;

  AuthRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  String get _loginUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth/login';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:5000/api/auth/login';
        }
      } catch (_) {}
      return 'http://localhost:5000/api/auth/login';
    }
  }

  String get _registerUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth/register';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:5000/api/auth/register';
        }
      } catch (_) {}
      return 'http://localhost:5000/api/auth/register';
    }
  }

  @override
  Future<void> initGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return;
    if (_googleSignInInitFuture != null) {
      return _googleSignInInitFuture;
    }
    _googleSignInInitFuture = () async {
      try {
        String? clientId;
        try {
          if (dotenv.isInitialized) {
            clientId = dotenv.env['GOOGLE_CLIENT_ID'];
          }
        } catch (_) {}
        clientId ??= ApiConfig.googleClientId;

        await GoogleSignIn.instance.initialize(
          clientId: clientId,
          serverClientId: kIsWeb ? null : clientId,
        );
        _isGoogleSignInInitialized = true;
      } catch (e) {
        _isGoogleSignInInitialized = true;
        debugPrint('[GoogleSignIn] Init notice: $e');
      }
    }();
    return _googleSignInInitFuture;
  }

  @override
  Future<GoogleIdentity?> signInWithGoogleSdk() async {
    await initGoogleSignIn();
    return await GoogleSignIn.instance.signIn();
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_loginUrl);
    final bodyStr = jsonEncode({
      'email': email,
      'password': password,
    });
    ApiLogger.logRequest('POST', uri, headers: {'Content-Type': 'application/json'}, body: bodyStr);

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: bodyStr,
    );
    ApiLogger.logResponse(response.statusCode, uri, body: response.body);

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'] as String?;
      final user = data['user'];
      String? userName;
      String? userEmail;

      if (user is Map) {
        userName = user['name']?.toString() ?? user['username']?.toString();
        userEmail = user['email']?.toString();
      }

      userName ??= email.contains('@') ? email.split('@')[0] : email;
      userEmail ??= email;

      await UserSession.instance.setUser(
        name: userName,
        email: userEmail,
        token: token,
        rawUser: user is Map<String, dynamic> ? user : null,
      );

      final authUser = AuthUser(
        name: userName,
        email: userEmail,
        token: token,
        rawUser: user is Map<String, dynamic> ? user : null,
      );

      return AuthResponse(
        success: true,
        message: data['message'] ?? 'Login berhasil',
        user: authUser,
        token: token,
      );
    } else {
      final errorMsg = data['message'] ?? 'Email atau kata sandi tidak valid.';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(_registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final token = data['token'] as String?;
      final user = data['user'];

      String resolvedName = name;
      String resolvedEmail = email;

      if (user is Map) {
        resolvedName = user['name']?.toString() ?? name;
        resolvedEmail = user['email']?.toString() ?? email;
      }

      await UserSession.instance.setUser(
        name: resolvedName,
        email: resolvedEmail,
        token: token,
        rawUser: user is Map<String, dynamic> ? user : null,
      );

      final authUser = AuthUser(
        name: resolvedName,
        email: resolvedEmail,
        phone: phone,
        token: token,
        rawUser: user is Map<String, dynamic> ? user : null,
      );

      return AuthResponse(
        success: true,
        message: data['message'] ?? 'Registrasi berhasil',
        user: authUser,
        token: token,
      );
    } else {
      final errorMsg = data['message'] ?? 'Pendaftaran akun gagal. Silakan coba lagi.';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<AuthResponse> processGoogleBackendLogin({
    required String email,
    String? name,
    String? photoUrl,
    String? googleId,
  }) async {
    final uri = Uri.parse(ApiConfig.googleLoginUrl);
    final bodyStr = jsonEncode({
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'googleId': googleId,
    });
    ApiLogger.logRequest('POST', uri, headers: {'Content-Type': 'application/json'}, body: bodyStr);

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: bodyStr,
    );
    ApiLogger.logResponse(response.statusCode, uri, body: response.body);

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'] as String?;
      final user = data['user'];
      final String resolvedName = (user is Map && user['name'] != null && user['name'].toString().trim().isNotEmpty)
          ? user['name'].toString().trim()
          : (name ?? email.split('@')[0]);
      final String resolvedEmail = (user is Map && user['email'] != null && user['email'].toString().trim().isNotEmpty)
          ? user['email'].toString().trim()
          : email;

      await UserSession.instance.setUser(
        name: resolvedName,
        email: resolvedEmail,
        token: token,
        rawUser: user is Map<String, dynamic> ? user : null,
      );

      final authUser = AuthUser(
        name: resolvedName,
        email: resolvedEmail,
        token: token,
        photoUrl: photoUrl,
        googleId: googleId,
        rawUser: user is Map<String, dynamic> ? user : null,
      );

      return AuthResponse(
        success: true,
        message: data['message'] ?? 'Login dengan Google berhasil',
        user: authUser,
        token: token,
      );
    } else {
      final errorMsg = data['message'] ?? 'Gagal masuk dengan akun Google.';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<void> forgotPassword(String identifier) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.forgotPasswordUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Gagal memproses permintaan. Silakan coba lagi.');
    }
  }

  @override
  Future<void> verifyResetAccount(String email, String phone) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.verifyResetAccountUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'phone': phone}),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Akun dengan kombinasi email dan nomor handphone tersebut tidak ditemukan.');
    }
  }

  @override
  Future<void> resetPasswordDirect(String email, String phone, String newPassword) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.resetPasswordDirectUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
        'newPassword': newPassword,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Gagal memperbarui kata sandi. Silakan coba lagi.');
    }
  }
}
