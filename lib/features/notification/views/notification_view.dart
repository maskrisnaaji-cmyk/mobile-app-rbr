import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/notification/models/notification_model.dart';
import 'package:mobile_app/features/notification/viewmodels/notification_viewmodel.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final NotificationViewModel _viewModel = NotificationViewModel.instance;

  @override
  void initState() {
    super.initState();
    _viewModel.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final notifications = _viewModel.filteredNotifications;
        final latestOrder = _viewModel.latestActiveOrderNotification;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F7F2), // Nuansa krem hangat RBR
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textMain),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Notifikasi & Status Pesanan',
              style: GoogleFonts.lora(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            actions: [
              if (_viewModel.unreadCount > 0)
                TextButton(
                  onPressed: _viewModel.markAllAsRead,
                  child: Text(
                    'Tandai Dibaca',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.maroon,
            onRefresh: _viewModel.fetchNotifications,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // ── 1. Live Order Tracker Banner ──────────────────────────────
                if (latestOrder != null) ...[
                  _buildLiveOrderTrackerCard(latestOrder),
                  const SizedBox(height: 16),
                ],

                // ── 2. Filter Tabs ───────────────────────────────────────────
                _buildFilterChips(),
                const SizedBox(height: 12),

                // ── 3. Daftar Notifikasi ─────────────────────────────────────
                if (_viewModel.isLoading && notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    ),
                  )
                else if (notifications.isEmpty)
                  _buildEmptyState()
                else
                  ...notifications.map((notif) => _buildNotificationCard(notif)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Banner pelacakan alur pesanan real-time dari dibuat hingga selesai
  Widget _buildLiveOrderTrackerCard(AppNotificationModel order) {
    final step = order.stepIndex; // 0: Dibuat, 1: Diproses, 2: Diantar, 3: Selesai

    final steps = [
      {'title': 'Dibuat', 'subtitle': 'Menunggu'},
      {'title': 'Diproses', 'subtitle': 'Diracik Barista'},
      {'title': 'Diantar', 'subtitle': 'Menuju Meja'},
      {'title': 'Selesai', 'subtitle': 'Diterima'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: order.statusBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(order.statusIcon, size: 16, color: order.statusColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status Pesanan Terkini',
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              if (order.orderId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    order.orderId!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Stepper bar
          Row(
            children: List.generate(4, (index) {
              final isPassed = index <= step;
              final isCurrent = index == step;

              return Expanded(
                child: Row(
                  children: [
                    // Dot
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isPassed ? AppColors.maroon : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(color: AppColors.maroon.withValues(alpha: 0.3), width: 4)
                            : null,
                      ),
                      child: Center(
                        child: isPassed
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // Line penghubung
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index < step ? AppColors.maroon : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Label steps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isCurrent = index == step;
              return SizedBox(
                width: 65,
                child: Text(
                  steps[index]['title']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? AppColors.maroon : AppColors.textMuted,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Info status & tombol simulasi progres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _viewModel.simulateNextStep(orderId: order.orderId);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.maroon,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Update Status',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pilihan filter notifikasi
  Widget _buildFilterChips() {
    final filters = ['Semua', 'Pesanan', 'Belum Dibaca'];

    return Row(
      children: filters.map((filter) {
        final isSelected = _viewModel.selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => _viewModel.setFilter(filter),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.maroon : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.maroon : AppColors.border,
                ),
              ),
              child: Text(
                filter,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMain,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Kartu notifikasi satuan
  Widget _buildNotificationCard(AppNotificationModel notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notif.isRead ? AppColors.border : AppColors.maroon.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _viewModel.markAsRead(notif.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon status
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: notif.statusBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notif.statusIcon, size: 20, color: notif.statusColor),
                ),
                const SizedBox(width: 12),

                // Teks notifikasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            notif.timeFormatted,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status pill dan Order ID
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: notif.statusBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notif.orderStatus,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: notif.statusColor,
                              ),
                            ),
                          ),
                          if (notif.orderId != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '#${notif.orderId}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.maroon,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.maroon.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 34,
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Notifikasi',
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pemberitahuan terkait status pesanan kedai atau tiket acara Anda akan muncul di sini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
