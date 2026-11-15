import 'package:flutter/material.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/agenda/views/agenda_view.dart';
import 'package:mobile_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:mobile_app/features/home/views/beranda_view.dart';
import 'package:mobile_app/features/kedai_kopi/views/kedai_kopi_view.dart';
import 'package:mobile_app/features/profil/views/profil_view.dart';
import 'package:mobile_app/features/pustaka/views/pustaka_view.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final HomeViewModel? viewModel;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.viewModel,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final HomeViewModel _viewModel;

  List<Widget> get _views => [
        BerandaView(
          viewModel: _viewModel,
          onNavigateTab: _onSelectTab,
        ),
        const KedaiKopiView(),
        const PustakaView(),
        const AgendaView(),
        const ProfilView(),
      ];

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AppInjection.createHomeViewModel();
    if (widget.initialIndex != 0) {
      _viewModel.setTabIndex(widget.initialIndex);
    }
  }

  void _onSelectTab(int index) {
    _viewModel.setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final selectedIndex = _viewModel.selectedTabIndex;

        return MobileFrame(
          child: Scaffold(
            backgroundColor: const Color(0xFFFAF7F2),
            body: _views[selectedIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.lightBorder.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomItem(0, Icons.home_outlined, Icons.home, 'Beranda', selectedIndex),
                  _buildBottomItem(1, Icons.local_cafe_outlined, Icons.local_cafe, 'Kedai Kopi', selectedIndex),
                  _buildBottomItem(2, Icons.menu_book_outlined, Icons.menu_book, 'Pustaka', selectedIndex),
                  _buildBottomItem(3, Icons.calendar_today_outlined, Icons.calendar_today, 'Agenda', selectedIndex),
                  _buildBottomItem(4, Icons.person_outline, Icons.person, 'Profil', selectedIndex),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int selectedIndex,
  ) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        if (index == 4 && selectedIndex != 4) {
          _onSelectTab(4);
        } else {
          _onSelectTab(index);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 22,
              color: isSelected ? AppColors.maroon : AppColors.greyText,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.maroon : AppColors.greyText,
              ),
            ),
            const SizedBox(height: 3),

            // Titik Indikator Khas di Bawah Menu Aktif
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.maroon,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
