// File: lib/screens/volunteer/tab_tre_em/phan_phat_qua_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../../../models/tab_tre_em_tnv.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../phuhuynh/detailsscreen/chi_tiet_su_kien_sk_screen.dart';
import 'chi_tiet_phan_phat_qua.dart';

class PhanPhatQuaTab extends StatefulWidget {
  const PhanPhatQuaTab({Key? key}) : super(key: key);

  @override
  State<PhanPhatQuaTab> createState() => _PhanPhatQuaTabState();
}

class _PhanPhatQuaTabState extends State<PhanPhatQuaTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.trePhanPhatQua.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Filter và Search
            _buildFilterAndSearch(provider),

            // List
            Expanded(
              child: _buildList(provider),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // FILTER VÀ SEARCH
  // ==========================================================================
  Widget _buildFilterAndSearch(VolunteerProvider provider) {
    return Container(
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      color: AppColors.surface,
      child: Column(
        children: [
          // Filter chips
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Tất cả',
                  icon: Icons.all_inclusive,
                  filter: 'TatCa',
                  isSelected: provider.filterPhanPhatQua == 'TatCa',
                  onTap: () => provider.changePhanPhatQuaFilter('TatCa'),
                ),
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: _buildFilterChip(
                  label: 'Đã nhận',
                  icon: Icons.check_circle,
                  filter: 'DaNhan',
                  isSelected: provider.filterPhanPhatQua == 'DaNhan',
                  onTap: () => provider.changePhanPhatQuaFilter('DaNhan'),
                ),
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: _buildFilterChip(
                  label: 'Đang tiến hành',
                  icon: Icons.pending,
                  filter: 'DangTienHanh',
                  isSelected: provider.filterPhanPhatQua == 'DangTienHanh',
                  onTap: () => provider.changePhanPhatQuaFilter('DangTienHanh'),
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacingSM),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên trẻ, khu phố...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  provider.searchPhanPhatQua('');
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusMD,
                ),
              ),
            ),
            onChanged: (value) {
              provider.searchPhanPhatQua(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required String filter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
        child: Container(
          padding: AppDimensions.paddingSymmetric(
            vertical: AppDimensions.spacingSM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSM,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
              SizedBox(width: AppDimensions.spacingXXS),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // LIST
  // ==========================================================================
  Widget _buildList(VolunteerProvider provider) {
    if (provider.trePhanPhatQua.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: AppDimensions.iconXXL,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: AppDimensions.spacingMD),
            Text(
              'Chưa có thông tin phân phát quà',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDanhSachTreEm(),
      child: ListView.builder(
        padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
        itemCount: provider.trePhanPhatQua.length,
        itemBuilder: (context, index) {
          return _buildPhanPhatQuaCard(provider.trePhanPhatQua[index]);
        },
      ),
    );
  }

  // ==========================================================================
  // CARD PHÂN PHÁT QUÀ
  // ==========================================================================
  Widget _buildPhanPhatQuaCard(TreEmPhanPhatQua item) {
    final baseUrl = 'http://10.0.2.2:5035';
    final trangThaiColor = item.trangThai == 'Đã nhận'
        ? AppColors.success
        : AppColors.warning;

    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: trangThaiColor,
            width: AppDimensions.borderExtraThick,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                builder: (context) => ChiTietPhanPhatQuaScreen(
                  phanPhatId: item.phanPhatID,
                ),
              ),
            );
          },
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          child: Padding(
            padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
            child: Row(
              children: [
                // Ảnh quà tặng
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusSM,
                    ),
                    color: AppColors.surfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusSM,
                    ),
                    child: item.anhQua != null && item.anhQua!.isNotEmpty
                        ? Image.network(
                      '$baseUrl${item.anhQua}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.card_giftcard,
                          size: AppDimensions.iconLG,
                          color: AppColors.textDisabled,
                        );
                      },
                    )
                        : Icon(
                      Icons.card_giftcard,
                      size: AppDimensions.iconLG,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),

                SizedBox(width: AppDimensions.spacingSM),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên trẻ
                      Text(
                        item.hoTen,
                        style: AppTextStyles.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimensions.spacingXXS),

                      // Tên quà
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppDimensions.spacingXXS),
                          Expanded(
                            child: Text(
                              item.tenQua,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.spacingXXS),

                      // Sự kiện
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppDimensions.spacingXXS),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (item.suKienID > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChiTietSuKienScreen(
                                        suKienId: item.suKienID,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                item.tenSuKien,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: item.suKienID > 0
                                      ? AppColors.info
                                      : AppColors.textSecondary,
                                  decoration: item.suKienID > 0
                                      ? TextDecoration.underline
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.spacingXXS),

                      // Ngày phát & Trạng thái
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: AppDimensions.iconXS - 2,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppDimensions.spacingXXS),
                          Text(
                            _formatDate(item.ngayPhanPhat),
                            style: AppTextStyles.caption,
                          ),
                          const Spacer(),
                          _buildTrangThaiChip(item.trangThai),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: AppDimensions.iconXS,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrangThaiChip(String trangThai) {
    final color = trangThai == 'Đã nhận'
        ? AppColors.success
        : AppColors.warning;
    final icon = trangThai == 'Đã nhận'
        ? Icons.check_circle
        : Icons.pending;

    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.chipPaddingH,
        vertical: AppDimensions.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: AppDimensions.spacingXXS),
          Text(
            trangThai,
            style: AppTextStyles.chip,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER
  // ==========================================================================
  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }
}