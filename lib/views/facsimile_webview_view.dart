import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

/// Halaman In-App WebView untuk pratinjau dokumen E-Faksimili & Flipbook
/// Membuka link langsung di dalam aplikasi (tanpa keluar ke browser),
/// dibungkus dalam MobileFrame proporsional, serta menginjeksi CSS/skala
/// agar tampilan dokumen/flipbook pihak ketiga (seperti FlipHTML5)
/// tersaji lurus, simetris di tengah, tidak miring, dan nyaman dibaca layaknya buku fisik.
class FacsimileWebViewView extends StatefulWidget {
  final String title;
  final String url;

  const FacsimileWebViewView({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<FacsimileWebViewView> createState() => _FacsimileWebViewViewState();
}

class _FacsimileWebViewViewState extends State<FacsimileWebViewView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isTakingTooLong = false;
  int _loadingProgress = 0;
  String? _errorMessage;
  double _currentZoom = 1.0;

  Timer? _longLoadingTimer;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void dispose() {
    _cancelTimers();
    // Bersihkan request WebGL/JavaScript dan unhook listener saat keluar untuk mencegah memory leak
    try {
      _controller?.loadRequest(Uri.parse('about:blank'));
    } catch (_) {}
    super.dispose();
  }

  void _startLoadingTimers() {
    _cancelTimers();

    // Jika setelah 8 detik masih loading, beri opsi tombol "Buka di Browser"
    _longLoadingTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        setState(() {
          _isTakingTooLong = true;
        });
      }
    });

    // Jika setelah 18 detik masih belum selesai, tampilkan error timeout dengan opsi browser
    _timeoutTimer = Timer(const Duration(seconds: 18), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _isTakingTooLong = false;
          _errorMessage =
              'Waktu memuat halaman habis (timeout). Situs eksternal mungkin membatasi penayangan di dalam WebView atau koneksi lambat.';
        });
      }
    });
  }

  void _cancelTimers() {
    _longLoadingTimer?.cancel();
    _longLoadingTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _initWebView() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF231F1D))
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                  if (progress >= 100) {
                    _isLoading = false;
                    _cancelTimers();
                  }
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                  _isTakingTooLong = false;
                });
                _startLoadingTimers();
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isTakingTooLong = false;
                });
                _cancelTimers();
                // Injeksi otomatis pengaturan tampilan buku fisik
                _applyBookModeStyles();
              }
            },
            onWebResourceError: (WebResourceError error) {
              // Abaikan pembatalan request biasa
              if (error.description.contains('net::ERR_ABORTED')) return;
              _cancelTimers();
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage =
                      'Kendala memuat dokumen (${error.errorCode}): ${error.description}.\nSitus eksternal mungkin membatasi iframe/WebView.';
                });
              }
            },
          ),
        );

      // Konfigurasi spesifik platform Android (DOM Storage, Media Playback tanpa gesture, Mixed Content, dsb)
      if (controller.platform is AndroidWebViewController) {
        final androidController = controller.platform as AndroidWebViewController;
        androidController.setMediaPlaybackRequiresUserGesture(false);
        androidController.setMixedContentMode(MixedContentMode.alwaysAllow);
        androidController.setUseWideViewPort(true);
        androidController.setAllowContentAccess(true);
        androidController.setAllowFileAccess(true);
      }

      final uri = Uri.tryParse(widget.url.trim());
      if (uri != null && uri.hasScheme) {
        controller.loadRequest(uri);
        _startLoadingTimers();
      } else {
        setState(() {
          _errorMessage = 'URL dokumen E-Faksimili tidak valid atau tidak lengkap.';
          _isLoading = false;
        });
      }

      _controller = controller;
    } catch (e) {
      debugPrint('[FacsimileWebView] Inisialisasi controller: $e');
      setState(() {
        _errorMessage = 'Gagal memuat penampil webview: $e';
        _isLoading = false;
      });
    }
  }

  /// Injeksi CSS & Viewport agar dokumen/flipbook tersaji lurus, simetris, tidak miring,
  /// dan menghilangkan banner/header yang mengganggu sensasi membaca buku fisik.
  Future<void> _applyBookModeStyles() async {
    if (_controller == null) return;

    const jsCode = r'''
    (function() {
      try {
        // 1. Standarisasi Viewport Meta agar proporsional di layar ponsel
        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, minimum-scale=0.5, user-scalable=yes';

        // 2. Injeksi Style Lembaran & Rak Buku Fisik (Menghilangkan miring / 3D skew)
        var styleId = 'rbr-book-realistic-styles';
        var style = document.getElementById(styleId);
        if (!style) {
          style = document.createElement('style');
          style.id = styleId;
          document.head.appendChild(style);
        }

        style.innerHTML = `
          /* Latar baca bernuansa kayu / kulit buku gelap elegan */
          html, body {
            margin: 0 !important;
            padding: 0 !important;
            width: 100% !important;
            height: 100% !important;
            background: #231F1D !important;
            overflow-x: hidden !important;
            overflow-y: auto !important;
            display: flex !important;
            flex-direction: column !important;
            justify-content: center !important;
            align-items: center !important;
            -webkit-font-smoothing: antialiased !important;
          }

          /* Container Flipbook / Dokumen: tegak lurus, presisi di tengah, hapus kemiringan */
          #fb-container, .flipbook, .flipbook-viewport, .magazine-viewport,
          .main-container, .fliphtml5-container, #container, .stage, #stage,
          .book-container, .page-container, #content, .reader-container, .p-container {
            margin: 0 auto !important;
            position: relative !important;
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            perspective: none !important;
            -webkit-perspective: none !important;
            transform: none !important;
            -webkit-transform: none !important;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.65) !important;
            border-radius: 4px !important;
          }

          /* Hilangkan elemen web yang mengganggu (header, iklan, watermark FlipHTML5 dsb) */
          .header, #header, .top-bar, #topbar, .banner, .ad, .advertisement,
          .watermark, .fh5-logo, .share-box, .fh5-brand, .copyright,
          .banner-ads, #fh5-ad-top, .fh5-header, .logo-bar {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
          }

          /* Canvas / Iframe buku dirender proporsional */
          canvas, iframe, img.page-img {
            max-width: 100% !important;
            height: auto !important;
            display: block !important;
            margin: 0 auto !important;
          }
        `;

        // 3. Trigger event resize agar mesin flipbook merender ulang secara simetris
        window.dispatchEvent(new Event('resize'));
      } catch (err) {
        console.log('[RBR Book Style Injection Error]:', err);
      }
    })();
    ''';

    try {
      await _controller?.runJavaScript(jsCode);
    } catch (_) {}

    // Jalankan ulang setelah jeda untuk memastikan komponen flipbook yang dimuat dinamis ikut terinjeksi
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        try {
          _controller?.runJavaScript(jsCode);
        } catch (_) {}
      }
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        try {
          _controller?.runJavaScript(jsCode);
        } catch (_) {}
      }
    });
  }

  /// Penyesuaian Skala Zoom Baca
  Future<void> _adjustZoom(double factor) async {
    final nextZoom = (_currentZoom * factor).clamp(0.6, 2.5);
    setState(() {
      _currentZoom = nextZoom;
    });

    final script = '''
      (function() {
        try {
          var target = document.querySelector('#fb-container') || 
                       document.querySelector('.flipbook') || 
                       document.querySelector('.stage') || 
                       document.body;
          if (target) {
            target.style.transform = 'scale($_currentZoom)';
            target.style.transformOrigin = 'center center';
          }
        } catch(e) {}
      })();
    ''';
    try {
      await _controller?.runJavaScript(script);
    } catch (_) {}
  }

  /// Reset Skala Tampilan Buku
  Future<void> _resetBookScale() async {
    setState(() {
      _currentZoom = 1.0;
    });
    await _applyBookModeStyles();
    const script = '''
      (function() {
        try {
          var target = document.querySelector('#fb-container') || 
                       document.querySelector('.flipbook') || 
                       document.querySelector('.stage') || 
                       document.body;
          if (target) {
            target.style.transform = 'scale(1)';
          }
          window.dispatchEvent(new Event('resize'));
        } catch(e) {}
      })();
    ''';
    try {
      await _controller?.runJavaScript(script);
    } catch (_) {}
  }

  Future<void> _openExternalFallback() async {
    final uri = Uri.tryParse(widget.url.trim());
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      outerBackgroundColor: const Color(0xFF1E1C1A),
      child: Scaffold(
        backgroundColor: const Color(0xFF231F1D),
        appBar: AppBar(
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'Kembali',
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories, size: 12, color: Color(0xFFFBC02D)),
                  const SizedBox(width: 4),
                  Text(
                    'PRATINJAU E-FAKSIMILI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: const Color(0xFFFBC02D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lora(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.fit_screen_rounded, size: 20),
              tooltip: 'Luruskan & Pas Layar',
              onPressed: _resetBookScale,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Muat Ulang',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _isTakingTooLong = false;
                  _errorMessage = null;
                });
                _startLoadingTimers();
                _controller?.reload();
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Opsi Dokumen',
              color: const Color(0xFF2D2724),
              onSelected: (val) {
                if (val == 'browser') {
                  _openExternalFallback();
                } else if (val == 'reset') {
                  _resetBookScale();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      const Icon(Icons.center_focus_strong, size: 18, color: Colors.white70),
                      const SizedBox(width: 10),
                      Text(
                        'Posisikan Tengah',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'browser',
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_browser, size: 18, color: Colors.white70),
                      const SizedBox(width: 10),
                      Text(
                        'Buka di Browser Luar',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBC02D)),
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: Column(
          children: [
            // Konten Utama WebView
            Expanded(
              child: Stack(
                children: [
                  _buildWebViewContent(),
                  if (_isLoading) _buildLoadingOverlay(),
                ],
              ),
            ),

            // Toolbar Kontrol Baca di Bawah (Ukuran & Navigasi Lembaran Buku)
            _buildBottomReaderBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book, size: 44, color: Color(0xFFEF5350)),
              ),
              const SizedBox(height: 16),
              Text(
                'Kendala Memuat Halaman Eksternal',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _openExternalFallback,
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: const Text('Buka di Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBC02D),
                      foregroundColor: const Color(0xFF3E2723),
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                        _isTakingTooLong = false;
                      });
                      _initWebView();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Coba Lagi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.maroon),
      );
    }

    return Container(
      color: const Color(0xFF231F1D),
      child: Center(
        child: WebViewWidget(controller: _controller!),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: const Color(0xFF1E1A18).withValues(alpha: 0.94),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.maroon.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFBC02D).withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 38,
                color: Color(0xFFFBC02D),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Menyiapkan E-Faksimili...',
              style: GoogleFonts.lora(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Menyelaraskan lembaran buku & tata letak digital',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBC02D)),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Opsi cadangan jika situs eksternal lama merespons
            if (_isTakingTooLong) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  'Situs eksternal memerlukan waktu muat lebih lama...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _openExternalFallback,
                icon: const Icon(Icons.open_in_browser, size: 16),
                label: const Text('Buka di Browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBC02D),
                  foregroundColor: const Color(0xFF3E2723),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Bottom Reader Bar untuk kemudahan navigasi skala seperti buku bacaan fisik
  Widget _buildBottomReaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1715),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Indikator Mode Buku
            Row(
              children: [
                const Icon(Icons.menu_book, size: 16, color: Color(0xFFFBC02D)),
                const SizedBox(width: 8),
                Text(
                  'Mode Baca Buku',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            // Tombol Skala & Posisi
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, size: 20),
                  color: Colors.white70,
                  tooltip: 'Perkecil',
                  onPressed: () => _adjustZoom(0.9),
                ),
                InkWell(
                  onTap: _resetBookScale,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '${(_currentZoom * 100).toInt()}% • Pas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFBC02D),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, size: 20),
                  color: Colors.white70,
                  tooltip: 'Perbesar',
                  onPressed: () => _adjustZoom(1.1),
                ),
                IconButton(
                  icon: const Icon(Icons.fit_screen, size: 19),
                  color: Colors.white70,
                  tooltip: 'Luruskan Posisi Lembaran',
                  onPressed: _resetBookScale,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
