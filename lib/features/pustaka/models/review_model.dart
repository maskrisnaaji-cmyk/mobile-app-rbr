/// Model data untuk ulasan & diskusi telaah naskah/buku
class BookReview {
  final String? id;
  final String bookTitle;
  final String author;
  final int rating;
  final String date;
  final String reviewText;
  final String? curatorReply;
  final int likes;
  final int comments;

  const BookReview({
    this.id,
    required this.bookTitle,
    required this.author,
    required this.rating,
    required this.date,
    required this.reviewText,
    this.curatorReply,
    this.likes = 0,
    this.comments = 0,
  });

  static List<BookReview> get demoReviews => const [
        BookReview(
          bookTitle: 'Dokumen Jibril',
          author: 'W.S. Rendra • Naskah Drama Klasik',
          rating: 5,
          date: '14 Sep 2026',
          reviewText:
              'Eksplorasi dialektika batin kemanusiaan yang sangat berani. Pementasan Bengkel Teater di naskah ini membuktikan kekuatan kritik sosial teater era 70-an yang tak lekang oleh waktu.',
          curatorReply:
              'Telaah yang tajam Mas Aris! Kami simpan manuskrip catatan panggung aslinya di Rak 3A.',
          likes: 12,
          comments: 4,
        ),
        BookReview(
          bookTitle: 'Alun-Alun Malang Tempo Doeloe',
          author: 'Dukut Imam Widodo • Sejarah Urban',
          rating: 5,
          date: '28 Agu 2026',
          reviewText:
              'Dokumentasi visual dan catatan urban landscape masa kolonial sangat lengkap. Sangat membantu riset sejarah tata ruang kota Malang tempo doeloe.',
          curatorReply: null,
          likes: 7,
          comments: 2,
        ),
        BookReview(
          bookTitle: 'Laki-Laki Yang Kawin Dengan Peri',
          author: 'Eka Kurniawan • Sastra Realisme Magis',
          rating: 4,
          date: '10 Agu 2026',
          reviewText:
              'Gaya bahasa lugas dan magis. Kumpulan cerpen yang memperlihatkan bagaimana mitos lokal nusantara bersilangan dengan kepedihan masyarakat kontemporer.',
          curatorReply:
              'Koleksi cerpen ini tersedia lengkap di Rak 2C untuk dibaca santai di teras belakang kedai.',
          likes: 9,
          comments: 1,
        ),
      ];
}
