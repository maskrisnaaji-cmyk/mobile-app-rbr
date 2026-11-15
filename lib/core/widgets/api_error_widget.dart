import 'package:flutter/material.dart';

/// Reusable Widget untuk menampilkan pesan error API / jaringan yang ramah pengguna
/// lengkap dengan tombol Coba Lagi / Retry agar aplikasi tidak force-close.
class ApiErrorWidget extends StatelessWidget {
  const ApiErrorWidget({
    super.key,
    this.message,
    this.statusCode,
    this.onRetry,
    this.compact = false,
  });

  final String? message;
  final int? statusCode;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _resolveTitle(statusCode);
    final description = message ?? _resolveDescription(statusCode);
    final icon = _resolveIcon(statusCode);

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B1D1B), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade900),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF6B1D1B)),
                tooltip: 'Coba Lagi',
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B1D18).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF6B1D1B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (statusCode != null) ...[
              const SizedBox(height: 6),
              Text(
                'Kode Status: $statusCode',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade400),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B1D1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _resolveTitle(int? code) {
    switch (code) {
      case 401:
        return 'Sesi Telah Berakhir';
      case 403:
        return 'Akses Terbatas';
      case 404:
        return 'Data Tidak Ditemukan';
      case 429:
        return 'Terlalu Banyak Permintaan';
      case null:
        return 'Gangguan Jaringan';
      default:
        return code >= 500 ? 'Kendala Server' : 'Terjadi Kesalahan';
    }
  }

  String _resolveDescription(int? code) {
    switch (code) {
      case 401:
        return 'Silakan login kembali untuk melanjutkan aktivitas Anda.';
      case 403:
        return 'Anda tidak memiliki hak akses untuk membuka konten ini.';
      case 404:
        return 'Konten atau data yang dicari tidak ditemukan.';
      case 429:
        return 'Terlalu banyak permintaan dalam waktu singkat. Mohon tunggu beberapa saat.';
      case null:
        return 'Periksa kembali koneksi internet Anda lalu coba muat ulang.';
      default:
        return code >= 500
            ? 'Server sedang dalam pemeliharaan. Silakan coba kembali beberapa saat lagi.'
            : 'Terjadi kesalahan sistem. Silakan coba lagi.';
    }
  }

  IconData _resolveIcon(int? code) {
    switch (code) {
      case 401:
      case 403:
        return Icons.lock_outline_rounded;
      case 404:
        return Icons.search_off_rounded;
      case 429:
        return Icons.hourglass_empty_rounded;
      case null:
        return Icons.wifi_off_rounded;
      default:
        return code >= 500
            ? Icons.cloud_off_rounded
            : Icons.error_outline_rounded;
    }
  }
}

