import 'package:flutter/foundation.dart';
import 'package:mobile_app/features/pustaka/models/book_model.dart';
import 'package:mobile_app/features/pustaka/models/favorite_model.dart';
import 'package:mobile_app/features/pustaka/models/loan_model.dart';
import 'package:mobile_app/features/pustaka/models/review_model.dart';
import 'package:mobile_app/features/pustaka/repositories/pustaka_repository.dart';

/// ViewModel untuk mengelola state katalog buku, pencarian, peminjaman, favorit, ulasan,
/// serta logika ketersediaan buku secara dinamis.
class PustakaViewModel extends ChangeNotifier {
  static final PustakaViewModel instance = PustakaViewModel._internal();

  factory PustakaViewModel({PustakaRepository? repository}) {
    if (repository != null) {
      return PustakaViewModel._internal(repository: repository);
    }
    return instance;
  }

  final PustakaRepository _repository;

  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  /// Set untuk melacak buku yang dipinjam secara dinamis
  final Set<String> _borrowedBookIds = {};

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

  PustakaViewModel._internal({PustakaRepository? repository})
      : _repository = repository ?? PustakaRepositoryImpl() {
    _allBooks = Book.dummyBooks;
    _filteredBooks = List.from(_allBooks);
    _initAndFetch();
  }

  /// Inisialisasi: muat daftar buku yang berstatus dipinjam dari repository/storage, lalu fetch data buku
  Future<void> _initAndFetch() async {
    try {
      final savedIds = await _repository.getBorrowedBookIdentifiers();
      _borrowedBookIds.addAll(savedIds);
    } catch (_) {}
    await fetchBooks();
  }

  List<Book> get allBooks => _allBooks;
  List<Book> get filteredBooks => _filteredBooks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;
  Set<String> get borrowedBookIds => Set.unmodifiable(_borrowedBookIds);

  List<LoanItem> get loans => _loans;
  bool get isLoanLoading => _isLoanLoading;

  List<FavoriteBook> get favorites => _favorites;
  List<BookReview> get reviews => _reviews;
  String? get errorMessage => _errorMessage;

  /// Cek apakah buku tertentu saat ini berstatus dipinjam secara dinamis
  bool isBookBorrowed(Book book) {
    if (_borrowedBookIds.contains(book.id.toLowerCase().trim()) ||
        _borrowedBookIds.contains(book.title.toLowerCase().trim())) {
      return true;
    }
    return book.isBorrowed;
  }

  /// Update status ketersediaan buku secara dinamis (misal: 'DIPINJAM' / 'DISEWAKAN' / 'TERSEDIA')
  void updateBookStatus(String bookIdOrTitle, String newStatus) {
    final key = bookIdOrTitle.toLowerCase().trim();
    final upper = newStatus.toUpperCase();

    if (upper == 'DIPINJAM' || upper == 'DISEWAKAN') {
      _borrowedBookIds.add(key);
      _repository.saveBorrowedBookIdentifier(key);
    } else if (upper == 'TERSEDIA') {
      _borrowedBookIds.remove(key);
      _repository.removeBorrowedBookIdentifier(key);
    }

    _allBooks = _allBooks.map((b) {
      if (b.id.toLowerCase().trim() == key || b.title.toLowerCase().trim() == key) {
        return b.copyWith(status: upper);
      }
      return b;
    }).toList();

    _applyFilter();
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.getBooks();
      if (loaded.isNotEmpty) {
        _allBooks = loaded.map((b) {
          if (_borrowedBookIds.contains(b.id.toLowerCase().trim()) ||
              _borrowedBookIds.contains(b.title.toLowerCase().trim())) {
            return b.copyWith(status: 'DIPINJAM');
          }
          final statusUpper = b.status.toUpperCase();
          if (statusUpper.isEmpty || statusUpper.contains('TERSEDIA')) {
            return b.copyWith(status: 'TERSEDIA');
          }
          return b;
        }).toList();
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

  Future<bool> requestLoan({
    required Book book,
    required String? token,
    String? memberName,
    String? memberEmail,
    String? memberPhone,
    String? identityNumber,
    String? notes,
    DateTime? customBorrowDate,
    int durationDays = 7,
  }) async {
    try {
      final today = customBorrowDate ?? DateTime.now();
      final dueDate = today.add(Duration(days: durationDays));
      String dateOnly(DateTime value) =>
          '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

      await _repository.requestLoan(
        bookCode: book.id,
        title: book.title,
        author: book.author,
        rackLocation: book.shelfLocation,
        borrowDate: dateOnly(today),
        dueDate: dateOnly(dueDate),
        token: token,
        memberName: memberName,
        memberEmail: memberEmail,
        memberPhone: memberPhone,
        identityNumber: identityNumber,
        notes: notes,
      );
      _errorMessage = null;

      // Perbarui status ketersediaan buku secara dinamis menjadi DIPINJAM
      if (book.id.isNotEmpty) {
        updateBookStatus(book.id, 'DIPINJAM');
      }
      updateBookStatus(book.title, 'DIPINJAM');

      // Update loans state jika ada session
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

  Future<bool> isBookFavorite(String title) async {
    return await _repository.isBookFavorite(title);
  }

  Future<bool> toggleFavorite(Book book) async {
    try {
      final isSaved = await _repository.isBookFavorite(book.title);
      if (isSaved) {
        await _repository.removeFavoriteBook(book.title);
      } else {
        await _repository.saveFavoriteBook(FavoriteBook.fromBook(book));
      }
      await fetchFavorites();
      return !isSaved; // return true jika baru saja disimpan
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchReviews() async {
    try {
      _reviews = await _repository.getReviews();
      notifyListeners();
    } catch (_) {}
  }
}
