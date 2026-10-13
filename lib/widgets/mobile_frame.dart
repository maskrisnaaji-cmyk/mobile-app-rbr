import 'package:flutter/material.dart';

/// Widget pembungkus untuk Flutter Web agar tampilan terkunci menyerupai
/// layar handphone (max-width 430px), terpusat, dengan latar luar gelap.
class MobileFrame extends StatelessWidget {
  /// Konten halaman yang akan dibungkus.
  final Widget child;

  /// Warna latar belakang di luar frame (default: gelap kecokelatan).
  final Color outerBackgroundColor;

  const MobileFrame({
    super.key,
    required this.child,
    this.outerBackgroundColor = const Color(0xFF1E1C1A),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: outerBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          height: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRect(
            child: child,
          ),
        ),
      ),
    );
  }
}
