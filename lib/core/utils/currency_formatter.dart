/// Utility helper untuk pemformatan mata uang Rupiah
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format angka integer ke string mata uang Rupiah (contoh: 25000 -> "Rp 25.000")
  static String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
