import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
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
  });
  Future<void> requestLoanExtension(String loanId, String? token);
  Future<List<FavoriteBook>> getFavoriteBooks();
  Future<List<BookReview>> getReviews();
}

/// Implementasi repository pustaka terintegrasi ke REST API backend dengan fallback data demo
class PustakaRepositoryImpl implements PustakaRepository {
  final http.Client _client;

  PustakaRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<Book>> getBooks() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.booksUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data
              .map((item) => Book.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback ke dummy books jika server offline
    }
    return Book.dummyBooks;
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
  }) async {
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/loans/request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bookCode': bookCode,
        'title': title,
        'author': author,
        'rackLocation': rackLocation,
        'borrowDate': borrowDate,
        'dueDate': dueDate,
      }),
    ).timeout(const Duration(seconds: 8));

    final body = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body is Map ? body['message'] ?? 'Pengajuan peminjaman gagal.' : 'Pengajuan peminjaman gagal.');
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
    return FavoriteBook.demoFavorites;
  }

  @override
  Future<List<BookReview>> getReviews() async {
    return BookReview.demoReviews;
  }
}
