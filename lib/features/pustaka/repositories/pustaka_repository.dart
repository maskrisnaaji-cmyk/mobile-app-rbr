import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/pustaka/models/book_model.dart';
import 'package:mobile_app/features/pustaka/models/favorite_model.dart';
import 'package:mobile_app/features/pustaka/models/loan_model.dart';
import 'package:mobile_app/features/pustaka/models/review_model.dart';

/// Kontrak repository untuk katalog pustaka, peminjaman fisik, favorit, dan ulasan
abstract class PustakaRepository {
  Future<List<Book>> getBooks();
  Future<Book?> getBookDetail(String id);
  Future<List<LoanItem>> getMyLoans(String? token);
  Future<void> requestLoan({
    required String bookCode,
    required String title,
    required String author,
    required String rackLocation,
    required String borrowDate,
    required String dueDate,
    required String? token,
    String? memberName,
    String? memberEmail,
    String? memberPhone,
    String? identityNumber,
    String? notes,
  });
  Future<void> requestLoanExtension(String loanId, String? token);
  Future<List<FavoriteBook>> getFavoriteBooks();
  Future<bool> saveFavoriteBook(FavoriteBook book);
  Future<bool> removeFavoriteBook(String title);
  Future<bool> isBookFavorite(String title);
  Future<List<BookReview>> getReviews();
  Future<Set<String>> getBorrowedBookIdentifiers();
  Future<void> saveBorrowedBookIdentifier(String identifier);
  Future<void> removeBorrowedBookIdentifier(String identifier);
}

/// Implementasi repository pustaka terintegrasi ke REST API backend dengan fallback data demo
class PustakaRepositoryImpl implements PustakaRepository {
  final http.Client _client;
  static const String _prefFavoritesKey = 'rbr_saved_favorite_books';
  static const String _prefBorrowedBooksKey = 'rbr_borrowed_books_identifiers';

  PustakaRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<Set<String>> getBorrowedBookIdentifiers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefBorrowedBooksKey);
      if (list != null) {
        return list.map((e) => e.toLowerCase().trim()).toSet();
      }
    } catch (_) {}
    return {};
  }

  @override
  Future<void> saveBorrowedBookIdentifier(String identifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = (prefs.getStringList(_prefBorrowedBooksKey) ?? []).toSet();
      current.add(identifier.toLowerCase().trim());
      await prefs.setStringList(_prefBorrowedBooksKey, current.toList());
    } catch (_) {}
  }

  @override
  Future<void> removeBorrowedBookIdentifier(String identifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = (prefs.getStringList(_prefBorrowedBooksKey) ?? []).toSet();
      current.remove(identifier.toLowerCase().trim());
      await prefs.setStringList(_prefBorrowedBooksKey, current.toList());
    } catch (_) {}
  }

  @override
  Future<List<Book>> getBooks() async {
    List<Book> books = [];
    bool isFromBackend = false;

    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.booksUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          books = data
              .map((item) => Book.fromJson(item as Map<String, dynamic>))
              .toList();
          isFromBackend = true;
        }
      }
    } catch (_) {
      // Fallback ke dummy books jika server offline
    }

    if (books.isEmpty) {
      books = List.from(Book.dummyBooks);
    }

    if (isFromBackend) {
      // Status buku membaca value langsung dari respons API backend (TERSEDIA vs DIPINJAM)
      return books;
    }

    // Fallback offline jika server backend tidak dapat dihubungi
    final borrowed = await getBorrowedBookIdentifiers();
    return books.map((b) {
      final isLocallyBorrowed = borrowed.contains(b.id.toLowerCase().trim()) ||
          borrowed.contains(b.title.toLowerCase().trim());
      if (isLocallyBorrowed) {
        return b.copyWith(status: 'DIPINJAM');
      }
      return b;
    }).toList();
  }

  @override
  Future<Book?> getBookDetail(String id) async {
    final all = await getBooks();
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return all.isNotEmpty ? all.first : null;
    }
  }

  @override
  Future<List<LoanItem>> getMyLoans(String? token) async {
    if (token == null || token.isEmpty) {
      return LoanItem.demoLoans;
    }

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/loans/my'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((item) => LoanItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback ke demo data
    }
    return LoanItem.demoLoans;
  }

  @override
  Future<void> requestLoan({
    required String bookCode,
    required String title,
    required String author,
    required String rackLocation,
    required String borrowDate,
    required String dueDate,
    required String? token,
    String? memberName,
    String? memberEmail,
    String? memberPhone,
    String? identityNumber,
    String? notes,
  }) async {
    final resolvedToken =
        (token != null && token.isNotEmpty) ? token : UserSession.instance.token;
    final userId = UserSession.instance.userId;
    final payload = {
      if (userId != null) 'user_id': userId,
      'bookCode': bookCode,
      'title': title,
      'author': author,
      'rackLocation': rackLocation,
      'borrowDate': borrowDate,
      'dueDate': dueDate,
      if (memberName != null && memberName.isNotEmpty) 'memberName': memberName,
      if (memberEmail != null && memberEmail.isNotEmpty) 'memberEmail': memberEmail,
      if (memberPhone != null && memberPhone.isNotEmpty) 'memberPhone': memberPhone,
      if (identityNumber != null && identityNumber.isNotEmpty) 'identityNumber': identityNumber,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/loans/request'),
        headers: {
          'Content-Type': 'application/json',
          if (resolvedToken != null && resolvedToken.isNotEmpty)
            'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body is Map ? body['message'] ?? 'Pengajuan peminjaman gagal.' : 'Pengajuan peminjaman gagal.');
      }
      // Catat buku sebagai dipinjam secara persisten
      if (bookCode.isNotEmpty) await saveBorrowedBookIdentifier(bookCode);
      if (title.isNotEmpty) await saveBorrowedBookIdentifier(title);
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      // Jika server offline / timeout, jangan lempar error yang memblokir flow demo
      if (bookCode.isNotEmpty) await saveBorrowedBookIdentifier(bookCode);
      if (title.isNotEmpty) await saveBorrowedBookIdentifier(title);
      return;
    }
  }

  @override
  Future<void> requestLoanExtension(String loanId, String? token) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/loans/extension'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'loanId': int.tryParse(loanId),
            'extensionDays': 7,
          }),
        )
        .timeout(const Duration(seconds: 8));

    final body = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Request perpanjangan gagal');
    }
  }

  @override
  Future<List<FavoriteBook>> getFavoriteBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefFavoritesKey);
      List<FavoriteBook> saved = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          saved = decoded.map((e) => FavoriteBook.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      // Gabungkan demo favorites jika belum ada dalam list tersimpan
      final Set<String> existingTitles = saved.map((b) => b.title.toLowerCase().trim()).toSet();
      for (final demo in FavoriteBook.demoFavorites) {
        if (!existingTitles.contains(demo.title.toLowerCase().trim())) {
          saved.add(demo);
        }
      }
      return saved;
    } catch (_) {
      return FavoriteBook.demoFavorites;
    }
  }

  @override
  Future<bool> saveFavoriteBook(FavoriteBook book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getFavoriteBooks();
      all.removeWhere((b) => b.title.toLowerCase().trim() == book.title.toLowerCase().trim());
      all.insert(0, book);
      final encoded = jsonEncode(all.map((e) => e.toJson()).toList());
      await prefs.setString(_prefFavoritesKey, encoded);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeFavoriteBook(String title) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getFavoriteBooks();
      all.removeWhere((b) => b.title.toLowerCase().trim() == title.toLowerCase().trim());
      final encoded = jsonEncode(all.map((e) => e.toJson()).toList());
      await prefs.setString(_prefFavoritesKey, encoded);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBookFavorite(String title) async {
    try {
      final all = await getFavoriteBooks();
      return all.any((b) => b.title.toLowerCase().trim() == title.toLowerCase().trim());
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<BookReview>> getReviews() async {
    return BookReview.demoReviews;
  }
}
