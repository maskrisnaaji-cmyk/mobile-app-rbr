import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central Session & State Management for logged-in user in Rumah Budaya Ratna
class UserSession extends ChangeNotifier {
  static final UserSession instance = UserSession._internal();
  factory UserSession() => instance;

  UserSession._internal() {
    init();
  }

  String _name = 'Ratna Anindita';
  String _email = 'ratna.anindita@budaya.id';
  String _initials = 'RA';
  String? _token;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  String get name => _name;
  String get email => _email;
  String get initials => _initials;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  /// Parse initials dynamically from user's name:
  /// Examples:
  /// - "n4yaaa" -> "N4" (single word, takes first 2 alphanumeric chars and uppercases)
  /// - "Aris Widiatmoko" -> "AW" (multiple words, takes first char of word 1 and word 2)
  /// - "Pengguna Google" -> "PG"
  /// - "Ratna Anindita" -> "RA"
  /// - "x" -> "X"
  static String parseInitials(String? name, {String fallback = 'RA'}) {
    if (name == null) return fallback;
    final cleaned = name.trim();
    if (cleaned.isEmpty) return fallback;

    // Split by any consecutive whitespace
    final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return fallback;

    if (parts.length == 1) {
      final word = parts[0];
      if (word.length >= 2) {
        return word.substring(0, 2).toUpperCase();
      }
      return word.toUpperCase();
    }

    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    final result = '$first$second'.toUpperCase();
    return result.isNotEmpty ? result : fallback;
  }

  /// Load session data asynchronously from SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('userName');
      final savedEmail = prefs.getString('userEmail');
      final savedToken = prefs.getString('token');
      final userStr = prefs.getString('user');

      String? resolvedName = savedName;
      String? resolvedEmail = savedEmail;

      if (userStr != null) {
        try {
          final userMap = jsonDecode(userStr);
          if (userMap is Map) {
            if ((resolvedName == null || resolvedName.trim().isEmpty) && userMap['name'] != null) {
              resolvedName = userMap['name'].toString();
            }
            if ((resolvedEmail == null || resolvedEmail.trim().isEmpty) && userMap['email'] != null) {
              resolvedEmail = userMap['email'].toString();
            }
          }
        } catch (_) {}
      }

      if (resolvedName != null && resolvedName.trim().isNotEmpty) {
        _name = resolvedName.trim();
        _initials = parseInitials(_name);
      }
      if (resolvedEmail != null && resolvedEmail.trim().isNotEmpty) {
        _email = resolvedEmail.trim();
      }
      _token = savedToken;
      _isLoggedIn = savedToken != null || savedName != null;
      _isInitialized = true;
      notifyListeners();
    } catch (_) {
      _isInitialized = true;
    }
  }

  /// Store session on login (works for both standard login and Google Sign-In)
  Future<void> setUser({
    required String name,
    String? email,
    String? token,
    Map<String, dynamic>? rawUser,
  }) async {
    _name = name.trim();
    _initials = parseInitials(_name);
    if (email != null && email.trim().isNotEmpty) {
      _email = email.trim();
    }
    if (token != null) {
      _token = token;
    }
    _isLoggedIn = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _name);
      if (email != null && email.trim().isNotEmpty) {
        await prefs.setString('userEmail', _email);
      }
      if (token != null) {
        await prefs.setString('token', token);
      }
      if (rawUser != null) {
        await prefs.setString('user', jsonEncode(rawUser));
      } else {
        await prefs.setString(
          'user',
          jsonEncode({
            'name': _name,
            'email': _email,
            'role': 'user',
          }),
        );
      }
    } catch (_) {}
  }

  /// Update user profile name and/or email
  Future<void> updateUser({required String name, String? email}) async {
    _name = name.trim();
    _initials = parseInitials(_name);
    if (email != null && email.trim().isNotEmpty) {
      _email = email.trim();
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _name);
      if (email != null && email.trim().isNotEmpty) {
        await prefs.setString('userEmail', _email);
      }

      final userStr = prefs.getString('user');
      Map<String, dynamic> userMap = {};
      if (userStr != null) {
        try {
          userMap = Map<String, dynamic>.from(jsonDecode(userStr));
        } catch (_) {}
      }
      userMap['name'] = _name;
      if (email != null) userMap['email'] = _email;
      await prefs.setString('user', jsonEncode(userMap));
    } catch (_) {}
  }

  /// Clear session on logout
  Future<void> clearSession() async {
    _name = 'Ratna Anindita';
    _email = 'ratna.anindita@budaya.id';
    _initials = 'RA';
    _token = null;
    _isLoggedIn = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}

