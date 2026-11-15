import 'package:flutter/foundation.dart';
import 'package:mobile_app/features/pustaka/models/book_model.dart';
import 'package:mobile_app/features/pustaka/models/favorite_model.dart';
import 'package:mobile_app/features/pustaka/models/loan_model.dart';
import 'package:mobile_app/features/pustaka/models/review_model.dart';
import 'package:mobile_app/features/pustaka/repositories/pustaka_repository.dart';

/// ViewModel untuk mengelola state katalog buku, pencarian, peminjaman, favorit, dan ulasan
class PustakaViewModel extends ChangeNotifier {
  final PustakaRepository _repository;

  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Sastra',
    'Sejarah',
    'Seni & Budaya',
  ];

  List<LoanItem> _loans = [];
  bool _isLoanLoading = false;

  List<FavoriteBook> _favorites = [];
  List<BookReview> _reviews = [];
  String? _errorMessage;

  PustakaViewModel({PustakaRepository? repository})
      : _repository = repository ?? PustakaRepositoryImpl() {
    _allBooks = Book.dummyBooks;
    _filteredBooks = List.from(_allBooks);
    fetchBooks();
  }

  List<Book> get allBooks => _allBooks;
  List<Book> get filteredBooks => _filteredBooks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  List<LoanItem> get loans => _loans;
  bool get isLoanLoading => _isLoanLoading;

  List<FavoriteBook> get favorites => _favorites;
  List<BookReview> get reviews => _reviews;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.getBooks();
      if (loaded.isNotEmpty) {
        _allBooks = loaded;
      }
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _applyFilter();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterBooks(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final query = _searchQuery.toLowerCase().trim();
    _filteredBooks = _allBooks.where((book) {
      final titleMatches = book.title.toLowerCase().contains(query);
      final authorMatches = book.author.toLowerCase().contains(query);
      final categoryMatches = book.category.toLowerCase().contains(query);

      final isCategorySelected = _selectedCategory == 'Semua' ||
          book.category == _selectedCategory ||
          book.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          (_selectedCategory == 'Seni & Budaya' && book.category.toLowerCase().contains('budaya'));

      return (titleMatches || authorMatches || categoryMatches) && isCategorySelected;
    }).toList();
  }

  Future<void> fetchLoans(String? token) async {
    _isLoanLoading = true;
    notifyListeners();

    try {
      _loans = await _repository.getMyLoans(token);
    } catch (_) {
      _loans = LoanItem.demoLoans;
    } finally {
      _isLoanLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestLoanExtension(LoanItem loan, String? token) async {
    if (loan.id == null) {
      _errorMessage = 'Data peminjaman belum tersinkron ke server admin.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.requestLoanExtension(loan.id!, token);
      await fetchLoans(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchFavorites() async {
    try {
      _favorites = await _repository.getFavoriteBooks();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchReviews() async {
    try {
      _reviews = await _repository.getReviews();
      notifyListeners();
    } catch (_) {}
  }
}
