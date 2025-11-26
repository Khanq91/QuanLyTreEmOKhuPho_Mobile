// screens/tinh_nguyen_vien/tnv_main_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/screen/tinhnguyenvien/mainscreen/su_kien_tab.dart';
import 'package:mobile/screen/tinhnguyenvien/mainscreen/tai_khoan_tab.dart';
import 'package:mobile/screen/tinhnguyenvien/mainscreen/thong_bao_tab.dart';
import 'package:mobile/screen/tinhnguyenvien/mainscreen/tre_em_tab.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import 'home_tab.dart';

final GlobalKey<VolunteerMainScreenState> volunteerMainScreenKey =
GlobalKey<VolunteerMainScreenState>();

class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerMainScreen> createState() => VolunteerMainScreenState();
}

class VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _selectedIndex = 0;

  void navigateToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      VolunteerHomeTab(),
      EventTab(),
      ChildrenTab(),
      ThongBaoScreen(),
      AccountTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: AppDimensions.bottomNavHeight,
            padding: AppDimensions.paddingSymmetric(
              horizontal: AppDimensions.spacingXS,
              vertical: AppDimensions.spacingXS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Trang chủ',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.event,
                  label: 'Sự kiện',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.child_care,
                  label: 'Trẻ em',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.notifications,
                  label: 'Thông báo',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person,
                  label: 'Tài khoản',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // NAV ITEM
  // ==========================================================================
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.radiusMD,
          ),
          child: AnimatedContainer(
            duration: AppDimensions.animationNormal,
            curve: Curves.easeInOut,
            padding: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryOverlay
                  : Colors.transparent,
              borderRadius: AppDimensions.radiusCircular(
                AppDimensions.radiusMD,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: AppDimensions.animationNormal,
                  curve: Curves.easeInOut,
                  child: Icon(
                    icon,
                    size: AppDimensions.iconMD,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXXS),

                // Label
                AnimatedDefaultTextStyle(
                  duration: AppDimensions.animationNormal,
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder screen for tabs not implemented yet
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Màn hình $title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang phát triển...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}