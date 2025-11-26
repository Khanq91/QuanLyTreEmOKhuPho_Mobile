// File: screens/tinh_nguyen_vien/lich_su_hoat_dong_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/tinh_nguyen_vien.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import '../../other/app_text.dart';
import '../../other/xem_anh_screen.dart';
import 'chi_tiet_su_kien.dart';

class LichSuHoatDongScreen extends StatefulWidget {
  const LichSuHoatDongScreen({Key? key}) : super(key: key);

  @override
  State<LichSuHoatDongScreen> createState() => _LichSuHoatDongScreenState();
}

class _LichSuHoatDongScreenState extends State<LichSuHoatDongScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<VolunteerProvider>();
      if (!provider.isLoading && provider.hasMoreData) {
        provider.loadLichSuHoatDong();
      }
    }
  }

  Future<void> _loadData() async {
    final provider = context.read<VolunteerProvider>();
    try {
      await provider.loadLichSuHoatDong(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Lịch sử hoạt động',
          style: AppTextStyles.appBarTitle,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Column(
            children: [
              // Search Bar
              // Padding(
              //   padding: AppDimensions.paddingSymmetric(
              //     horizontal: AppDimensions.spacingMD,
              //     vertical: AppDimensions.spacingSM,
              //   ),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: AppColors.surface,
              //       borderRadius: AppDimensions.radiusCircular(
              //         AppDimensions.radiusFull,
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.05),
              //           blurRadius: 8,
              //           offset: const Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     child: TextField(
              //       controller: _searchController,
              //       style: AppTextStyles.bodyMedium,
              //       decoration: InputDecoration(
              //         hintText: 'Tìm theo tên khu phố...',
              //         hintStyle: AppTextStyles.bodyMedium.copyWith(
              //           color: AppColors.textHint,
              //         ),
              //         prefixIcon: Icon(
              //           Icons.search_rounded,
              //           color: AppColors.textSecondary,
              //           size: AppDimensions.iconMD,
              //         ),
              //         suffixIcon: _searchController.text.isNotEmpty
              //             ? IconButton(
              //           icon: Icon(
              //             Icons.clear_rounded,
              //             color: AppColors.textSecondary,
              //             size: AppDimensions.iconSM,
              //           ),
              //           onPressed: () {
              //             setState(() => _searchController.clear());
              //             context.read<VolunteerProvider>().setFilterKhuPho(null);
              //           },
              //         )
              //             : null,
              //         filled: false,
              //         border: InputBorder.none,
              //         contentPadding: AppDimensions.paddingSymmetric(
              //           horizontal: AppDimensions.spacingMD,
              //           vertical: AppDimensions.spacingSM,
              //         ),
              //       ),
              //       onSubmitted: (value) {
              //         context.read<VolunteerProvider>().setFilterKhuPho(
              //           value.isEmpty ? null : value,
              //         );
              //       },
              //     ),
              //   ),
              // ),

              // Tab Bar
              Container(
                margin: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelMedium,
                  tabs: const [
                    Tab(text: 'Sự kiện'),
                    Tab(text: 'Hỗ trợ PL'),
                    Tab(text: 'Vận động'),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacingSM),
            ],
          ),
        ),
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.lichSuHoatDong == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (provider.lichSuHoatDong == null) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSuKienTab(provider),
              _buildHoTroTab(provider),
              _buildVanDongTab(provider),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // SỰ KIỆN TAB
  // ==========================================================================
  Widget _buildSuKienTab(VolunteerProvider provider) {
    final suKienList = provider.lichSuHoatDong!.suKienDaThamGia;

    if (suKienList.isEmpty) {
      return _buildEmptyState(
        message: 'Chưa tham gia sự kiện nào',
        icon: Icons.event_busy_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: suKienList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == suKienList.length) {
            return _buildLoadingIndicator();
          }

          final suKien = suKienList[index];
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Container(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.primaryOverlay,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.event_rounded,
                          color: AppColors.primary,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suKien.tenSuKien,
                              style: AppTextStyles.headingSmall,
                            ),
                            if (suKien.tenKhuPho != null) ...[
                              SizedBox(height: AppDimensions.spacingXXS),
                              Text(
                                suKien.tenKhuPho!,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.location_on_rounded,
                    suKien.diaDiem ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    '${suKien.ngayBatDau != null ? dateFormat.format(suKien.ngayBatDau!) : 'N/A'} - ${suKien.ngayKetThuc != null ? dateFormat.format(suKien.ngayKetThuc!) : 'N/A'}',
                  ),

                  SizedBox(height: AppDimensions.spacingSM),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(suKienId: suKien.suKienID!),
                          ),
                        );
                      },
                      icon: Icon(Icons.event, color: AppColors.textOnPrimary),
                      label: Text(
                        "Xem chi tiết",
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // HỖ TRỢ PHÚC LỢI TAB
  // ==========================================================================
  Widget _buildHoTroTab(VolunteerProvider provider) {
    final quaList = provider.lichSuHoatDong!.quaDaPhanPhat;

    if (quaList.isEmpty) {
      return _buildEmptyState(
        message: 'Chưa có phân phát quà nào',
        icon: Icons.card_giftcard_outlined,
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: quaList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == quaList.length) {
            return _buildLoadingIndicator();
          }

          final item = quaList[index];

          return Container(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.successOverlay,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------
                  //       TIÊU ĐỀ CARD
                  // ---------------------------
                  Row(
                    children: [
                      Container(
                        padding:
                        AppDimensions.paddingAll(AppDimensions.spacingSM),
                        decoration: BoxDecoration(
                          color: AppColors.successOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: AppColors.success,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),

                      // Tên trẻ | Tên quà
                      Expanded(
                        child: Text(
                          "${item.tenTreEm} | ${item.tenQua}",
                          style: AppTextStyles.headingSmall,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  if (item.trangThai.isNotEmpty)  ...[
                    _buildStatusChip(item.trangThai)
                  ],
                  SizedBox(height: AppDimensions.spacingSM),

                  // ---------------------------
                  //        CHI TIẾT QUÀ
                  // ---------------------------
                  _buildInfoRow(
                    Icons.cake,
                    "Số lượng: ${item.soLuongNhan}",
                  ),

                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    dateFormat.format(DateTime.parse(item.ngayPhanPhat)),
                  ),

                  if (item.tenSuKien != null && item.suKienID != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(suKienId: item.suKienID!),
                          ),
                        );
                      },
                      child: _buildInfoRow(
                        Icons.event,
                        item.tenSuKien!,
                        isLink: true,
                      ),
                    ),

                  // ---------------------------
                  //      NÚT XEM ẢNH
                  // ---------------------------
                  if (item.anh.isNotEmpty) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageViewerScreen(
                                imageUrl: item.anh,
                                title: item.tenQua,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.image, color: AppColors.textOnPrimary),
                        label: Text(
                          "Xem ảnh",
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textOnPrimary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildStatusChip(String trangThai) {
    Color color;
    Color bg;

    switch (trangThai.toLowerCase()) {
      case "Đã phát":
      case "đã nhận":
      case "đã phát thành công":
        color = AppColors.success;
        bg = AppColors.successOverlay;
        break;

      case "chưa phát":
        color = AppColors.warning;
        bg = AppColors.warningOverlay;
        break;

      case "hẹn lại":
        color = AppColors.info;
        bg = AppColors.infoOverlay;
        break;

      default:
        color = AppColors.textSecondary;
        bg = AppColors.background;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        trangThai,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Helper row UI (nếu cần link)
  Widget _buildInfoRow(IconData icon, String text, {bool isLink = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spacingXS),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSM,
            color: isLink ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLink ? AppColors.primary : AppColors.textSecondary,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================================
  // VẬN ĐỘNG TRẺ EM TAB
  // ==========================================================================
  Widget _buildVanDongTab(VolunteerProvider provider) {
    final vanDongList = provider.lichSuHoatDong!.treEmDaVanDong;

    if (vanDongList.isEmpty) {
      return _buildEmptyState(
        message: 'Chưa vận động trẻ em nào',
        icon: Icons.child_care_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: vanDongList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vanDongList.length) {
            return _buildLoadingIndicator();
          }

          final vanDong = vanDongList[index];
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Container(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.warningOverlay,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                        decoration: BoxDecoration(
                          color: AppColors.warningOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.child_care_rounded,
                          color: AppColors.warning,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vanDong.tenTreEm,
                              style: AppTextStyles.headingSmall,
                            ),
                            SizedBox(height: AppDimensions.spacingXXS),
                            Row(
                              children: [
                                Icon(
                                  vanDong.gioiTinh == 'Nam'
                                      ? Icons.male_rounded
                                      : Icons.female_rounded,
                                  size: AppDimensions.iconXS,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: AppDimensions.spacingXXS),
                                Text(
                                  vanDong.gioiTinh ?? 'N/A',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  ' • ',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Expanded(
                                  child: Text(
                                    vanDong.tenKhuPho ?? 'N/A',
                                    style: AppTextStyles.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (vanDong.tinhTrangCapNhat != null)
                        Container(
                          padding: AppDimensions.paddingSymmetric(
                            horizontal: AppDimensions.spacingSM,
                            vertical: AppDimensions.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: _getTinhTrangColor(vanDong.tinhTrangCapNhat!).withOpacity(0.15),
                            borderRadius: AppDimensions.radiusCircular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            vanDong.tinhTrangCapNhat!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getTinhTrangColor(vanDong.tinhTrangCapNhat!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.report_problem_rounded,
                          'Hoàn cảnh: ${vanDong.loaiHoanCanh ?? 'N/A'}',
                          isLink: false,
                        ),
                        _buildInfoRow(
                          Icons.description_rounded,
                          'Lý do: ${vanDong.lyDo ?? 'N/A'}',
                          isLink: false,
                        ),
                        _buildInfoRow(
                          Icons.check_circle_rounded,
                          'Kết quả: ${vanDong.ketQua ?? 'N/A'}',
                          isLink: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    vanDong.ngayVanDong != null
                        ? dateFormat.format(vanDong.ngayVanDong!)
                        : 'N/A',
                  ),
                  if (vanDong.ghiChuChiTiet != null) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Container(
                      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                      decoration: BoxDecoration(
                        color: AppColors.infoOverlay,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusSM,
                        ),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.2),
                          width: AppDimensions.borderThin,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: AppDimensions.iconXS,
                            color: AppColors.info,
                          ),
                          SizedBox(width: AppDimensions.spacingXS),
                          Expanded(
                            child: Text(
                              vanDong.ghiChuChiTiet!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message, IconData? icon}) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.primaryOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                size: AppDimensions.iconXXL,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingLG),
            Text(
              message ?? 'Không có dữ liệu',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingXS),
            Text(
              'Dữ liệu sẽ xuất hiện khi có hoạt động mới',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTinhTrangColor(String tinhTrang) {
    switch (tinhTrang) {
      case 'Đi học':
        return AppColors.success;
      case 'Nghỉ học':
        return AppColors.warning;
      case 'Nguy cơ bỏ học':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}