import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/mainscreen/su_kien_tab.dart';
import 'package:mobile/screen/phuhuynh/mainscreen/tai_khoan_tab.dart';
import 'package:mobile/screen/phuhuynh/mainscreen/thong_bao_tab.dart';
import 'package:mobile/screen/phuhuynh/mainscreen/tre_em_tab.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import 'home_tab.dart';


final GlobalKey<ParentMainScreenState> parentMainScreenKey =
GlobalKey<ParentMainScreenState>();

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({Key? key}) : super(key: key);

  @override
  State<ParentMainScreen> createState() => ParentMainScreenState();
}

class ParentMainScreenState extends State<ParentMainScreen> {
  int _selectedIndex = 0;

  void navigateToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Khai báo screens trong build method
    final screens = const [
      ParentHomeTab(),
      ParentChildrenScreen(),
      SuKienScreen(),
      TabThongBaoScreen(),
      TabTaiKhoanScreen(),
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
                  icon: Icons.child_care,
                  label: 'Con tôi',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.event,
                  label: 'Sự kiện',
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