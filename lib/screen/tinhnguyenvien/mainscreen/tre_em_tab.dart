import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/providers/tinh_nguyen_vien.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../detailsscreen/chi_tiet_ho_tro.dart';
import '../detailsscreen/chi_tiet_van_dong.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class ChildrenTab extends StatefulWidget {
  const ChildrenTab({Key? key}) : super(key: key);

  @override
  State<ChildrenTab> createState() => _ChildrenTabState();
}

class _ChildrenTabState extends State<ChildrenTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<VolunteerProvider>(context, listen: false);
    await provider.loadDanhSachTreEm();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quản lý Trẻ em', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        elevation: AppDimensions.elevationNone,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.appBarText,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnPrimary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
          tabs: [
            Tab(
              icon: Icon(Icons.child_care, size: AppDimensions.iconMD),
              text: 'Trẻ cần vận động',
            ),
            Tab(
              icon: Icon(Icons.card_giftcard, size: AppDimensions.iconMD),
              text: 'Phát hỗ trợ phúc lợi',
            ),
          ],
        ),
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: AppDimensions.spacingMD),
                  Text(
                    'Đang tải dữ liệu...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingXXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spacingXL),
                      decoration: BoxDecoration(
                        color: AppColors.errorOverlay,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: AppDimensions.iconXXL,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXL),
                    Text(
                      'Đã có lỗi xảy ra',
                      style: AppTextStyles.headingLarge,
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXL),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingXL,
                          vertical: AppDimensions.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                        elevation: AppDimensions.elevationNone,
                      ),
                      icon: Icon(Icons.refresh, size: AppDimensions.iconSM),
                      label: Text('Thử lại', style: AppTextStyles.button),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTreCanVanDongTab(provider),
                _buildTrePhatHoTroTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============ TAB TRẺ CẦN VẬN ĐỘNG ============

  Widget _buildTreCanVanDongTab(VolunteerProvider provider) {
    if (provider.treCanVanDong.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spacingXL),
                decoration: BoxDecoration(
                  color: AppColors.infoOverlay,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.child_friendly,
                  size: AppDimensions.iconXXL,
                  color: AppColors.info,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXL),
              Text(
                'Chưa có trẻ được phân công',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXS),
              Text(
                'Bạn sẽ nhận được thông báo khi được phân công vận động trẻ em',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.spacingMD),
      itemCount: provider.treCanVanDong.length,
      itemBuilder: (context, index) {
        final tre = provider.treCanVanDong[index];
        return _buildTreCanVanDongCard(tre);
      },
    );
  }

  Widget _buildTreCanVanDongCard(tre) {
    final age = DateTime.now().year - tre.ngaySinh.year;

    Color getBadgeColor() {
      switch (tre.tinhTrang.toLowerCase()) {
        case 'đi học':
          return AppColors.success;
        case 'nghỉ học':
          return AppColors.warning;
        case 'nguy cơ bỏ học':
          return AppColors.error;
        default:
          return AppColors.textDisabled;
      }
    }

    IconData getStatusIcon() {
      switch (tre.tinhTrang.toLowerCase()) {
        case 'đi học':
          return Icons.school;
        case 'nghỉ học':
          return Icons.pause_circle_outline;
        case 'nguy cơ bỏ học':
          return Icons.warning;
        default:
          return Icons.help_outline;
      }
    }

    final badgeColor = getBadgeColor();

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: AppDimensions.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChiTietTreVanDongScreen(treEmId: tre.treEmID),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMD),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badgeColor.withOpacity(0.5),
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: badgeColor.withOpacity(0.1),
                    backgroundImage: tre.anh != null
                        ? NetworkImage('$baseUrl${tre.anh}')
                        : null,
                    child: tre.anh == null
                        ? Icon(
                      tre.gioiTinh == 'Nam' ? Icons.boy : Icons.girl,
                      size: AppDimensions.iconLG,
                      color: badgeColor,
                    )
                        : null,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingMD),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tre.hoTen,
                        style: AppTextStyles.headingSmall,
                      ),
                      SizedBox(height: AppDimensions.spacingXS),

                      // Tuổi & Giới tính
                      Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$age tuổi',
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(width: AppDimensions.spacingSM),
                          Icon(
                            tre.gioiTinh == 'Nam' ? Icons.male : Icons.female,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            tre.gioiTinh,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingXS),

                      // Địa chỉ
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tre.diaChi,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingSM),

                      // Badges
                      Row(
                        children: [
                          // Tình trạng
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingSM,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                                border: Border.all(
                                  color: badgeColor.withOpacity(0.5),
                                  width: AppDimensions.borderMedium,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    getStatusIcon(),
                                    size: 14,
                                    color: badgeColor,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      tre.tinhTrang,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: badgeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingXS),

                          // Số lần vận động
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSM,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryOverlay,
                              borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.5),
                                width: AppDimensions.borderMedium,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${tre.soLanVanDong} lần',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: AppDimensions.iconMD,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ TAB TRẺ PHÁT HỖ TRỢ PHÚC LỢI ============

  Widget _buildTrePhatHoTroTab(VolunteerProvider provider) {
    if (provider.trePhatHoTro.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spacingXL),
                decoration: BoxDecoration(
                  color: AppColors.accentOverlay,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: AppDimensions.iconXXL,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXL),
              Text(
                'Chưa có trẻ được phân công',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXS),
              Text(
                'Bạn sẽ nhận được thông báo khi được phân công phát hỗ trợ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.spacingMD),
      itemCount: provider.trePhatHoTro.length,
      itemBuilder: (context, index) {
        final tre = provider.trePhatHoTro[index];
        return _buildTrePhatHoTroCard(tre);
      },
    );
  }

  Widget _buildTrePhatHoTroCard(tre) {
    final age = DateTime.now().year - tre.ngaySinh.year;

    Color getStatusColor() {
      switch (tre.trangThaiPhat.toLowerCase()) {
        case 'đã phát thành công':
          return AppColors.success;
        case 'chưa nhận':
          return AppColors.warning;
        case 'lần đầu':
        case 'chưa phát':
          return AppColors.info;
        default:
          return AppColors.textDisabled;
      }
    }

    IconData getLoaiIcon() {
      final loai = tre.loaiHoTro.toLowerCase();
      if (loai.contains('học')) return Icons.school;
      if (loai.contains('quà')) return Icons.card_giftcard;
      if (loai.contains('trang phục')) return Icons.checkroom;
      return Icons.favorite;
    }

    IconData getStatusIcon() {
      switch (tre.trangThaiPhat.toLowerCase()) {
        case 'đã phát thành công':
          return Icons.check_circle;
        case 'chưa nhận':
          return Icons.schedule;
        case 'lần đầu':
        case 'chưa phát':
          return Icons.fiber_new;
        default:
          return Icons.help_outline;
      }
    }

    final statusColor = getStatusColor();

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: AppDimensions.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChiTietTreHoTroScreen(hoTroId: tre.hoTroID),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMD),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: statusColor.withOpacity(0.1),
                    backgroundImage: tre.anh != null
                        ? NetworkImage('$baseUrl${tre.anh}')
                        : null,
                    child: tre.anh == null
                        ? Icon(
                      tre.gioiTinh == 'Nam' ? Icons.boy : Icons.girl,
                      size: AppDimensions.iconLG,
                      color: statusColor,
                    )
                        : null,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingMD),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tre.hoTen,
                        style: AppTextStyles.headingSmall,
                      ),
                      SizedBox(height: AppDimensions.spacingXS),

                      // Tuổi & Giới tính
                      Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$age tuổi',
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(width: AppDimensions.spacingSM),
                          Icon(
                            tre.gioiTinh == 'Nam' ? Icons.male : Icons.female,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            tre.gioiTinh,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingXS),

                      // Địa chỉ
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tre.diaChi,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingSM),

                      // Badges
                      Wrap(
                        spacing: AppDimensions.spacingXS,
                        runSpacing: AppDimensions.spacingXS,
                        children: [
                          // Loại hỗ trợ
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSM,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentOverlay,
                              borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.5),
                                width: AppDimensions.borderMedium,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  getLoaiIcon(),
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  tre.loaiHoTro,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Trạng thái phát
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSM,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                                width: AppDimensions.borderMedium,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  getStatusIcon(),
                                  size: 14,
                                  color: statusColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  tre.trangThaiPhat,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Ngày hẹn lại (nếu có)
                          if (tre.ngayHenLai != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingSM,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorOverlay,
                                borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.5),
                                  width: AppDimensions.borderMedium,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Hẹn ${DateFormat('dd/MM').format(tre.ngayHenLai!)}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: AppDimensions.iconMD,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}