// File: screens/tinh_nguyen_vien/lich_su_hoat_dong_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/tinh_nguyen_vien.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import '../../other/app_text.dart';

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
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingSM,
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên khu phố...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        setState(() => _searchController.clear());
                        context.read<VolunteerProvider>().setFilterKhuPho(null);
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusFull,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: AppDimensions.paddingSymmetric(
                      horizontal: AppDimensions.spacingMD,
                      vertical: AppDimensions.spacingSM,
                    ),
                  ),
                  onSubmitted: (value) {
                    context.read<VolunteerProvider>().setFilterKhuPho(
                      value.isEmpty ? null : value,
                    );
                  },
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textOnPrimary,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.6),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.labelMedium,
                tabs: const [
                  Tab(text: 'Sự kiện'),
                  Tab(text: 'Hỗ trợ PL'),
                  Tab(text: 'Vận động'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.lichSuHoatDong == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
      return _buildEmptyState(message: 'Chưa tham gia sự kiện nào');
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

          return Card(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
            ),
            elevation: AppDimensions.elevationSM,
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
                          Icons.event,
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
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (suKien.tenKhuPho != null)
                              Text(
                                suKien.tenKhuPho!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.location_on,
                    suKien.diaDiem ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${suKien.ngayBatDau != null ? dateFormat.format(suKien.ngayBatDau!) : 'N/A'} - ${suKien.ngayKetThuc != null ? dateFormat.format(suKien.ngayKetThuc!) : 'N/A'}',
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
    final hoTroList = provider.lichSuHoatDong!.hoTroPhucLoiDaPhat;

    if (hoTroList.isEmpty) {
      return _buildEmptyState(message: 'Chưa phát hỗ trợ phúc lợi nào');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: hoTroList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == hoTroList.length) {
            return _buildLoadingIndicator();
          }

          final hoTro = hoTroList[index];
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Card(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
            ),
            elevation: AppDimensions.elevationSM,
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
                          color: AppColors.successOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          color: AppColors.success,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hoTro.loaiHoTro,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hoTro.tenTreEm != null)
                              Text(
                                'Trẻ em: ${hoTro.tenTreEm}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: AppDimensions.paddingSymmetric(
                          horizontal: AppDimensions.spacingSM,
                          vertical: AppDimensions.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Text(
                          hoTro.trangThaiPhat ?? 'N/A',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hoTro.moTa != null) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Text(
                      hoTro.moTa!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.location_on,
                    hoTro.tenKhuPho ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    hoTro.ngayCap != null ? dateFormat.format(hoTro.ngayCap!) : 'N/A',
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
  // VẬN ĐỘNG TRẺ EM TAB
  // ==========================================================================
  Widget _buildVanDongTab(VolunteerProvider provider) {
    final vanDongList = provider.lichSuHoatDong!.treEmDaVanDong;

    if (vanDongList.isEmpty) {
      return _buildEmptyState(message: 'Chưa vận động trẻ em nào');
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

          return Card(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
            ),
            elevation: AppDimensions.elevationSM,
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
                          Icons.child_care,
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
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${vanDong.gioiTinh ?? 'N/A'} • ${vanDong.tenKhuPho ?? 'N/A'}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
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
                            color: _getTinhTrangColor(vanDong.tinhTrangCapNhat!).withOpacity(0.2),
                            borderRadius: AppDimensions.radiusCircular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            vanDong.tinhTrangCapNhat!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getTinhTrangColor(vanDong.tinhTrangCapNhat!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.report_problem,
                    'Hoàn cảnh: ${vanDong.loaiHoanCanh ?? 'N/A'}',
                  ),
                  _buildInfoRow(
                    Icons.description,
                    'Lý do: ${vanDong.lyDo ?? 'N/A'}',
                  ),
                  _buildInfoRow(
                    Icons.check_circle,
                    'Kết quả: ${vanDong.ketQua ?? 'N/A'}',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    vanDong.ngayVanDong != null
                        ? dateFormat.format(vanDong.ngayVanDong!)
                        : 'N/A',
                  ),
                  if (vanDong.ghiChuChiTiet != null) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Container(
                      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusSM,
                        ),
                      ),
                      child: Text(
                        'Ghi chú: ${vanDong.ghiChuChiTiet}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: AppDimensions.paddingSymmetric(vertical: AppDimensions.spacingXS),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(
            message ?? 'Không có dữ liệu',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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