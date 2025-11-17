// File: lib/screens/volunteer/detailsscreen/chi_tiet_phan_phat_qua_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../../../models/tab_tre_em_tnv.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../phuhuynh/detailsscreen/chi_tiet_su_kien_sk_screen.dart';
import '../../other/xem_anh_screen.dart';

class ChiTietPhanPhatQuaScreen extends StatefulWidget {
  final int phanPhatId;

  const ChiTietPhanPhatQuaScreen({
    Key? key,
    required this.phanPhatId,
  }) : super(key: key);

  @override
  State<ChiTietPhanPhatQuaScreen> createState() =>
      _ChiTietPhanPhatQuaScreenState();
}

class _ChiTietPhanPhatQuaScreenState extends State<ChiTietPhanPhatQuaScreen> {
  final TextEditingController _ghiChuController = TextEditingController();
  String _selectedTrangThai = 'Đang tiến hành';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<VolunteerProvider>();
    await provider.loadChiTietTrePhanPhatQua(widget.phanPhatId);

    // Set initial values
    if (provider.chiTietTrePhanPhatQua != null) {
      final chiTiet = provider.chiTietTrePhanPhatQua!;
      setState(() {
        _selectedTrangThai = chiTiet.trangThai;
        _ghiChuController.text = chiTiet.ghiChu ?? '';
        _selectedDate = DateTime.parse(chiTiet.ngayPhanPhat);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chi tiết phân phát quà', style: AppTextStyles.appBarTitle),
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.chiTietTrePhanPhatQua == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final chiTiet = provider.chiTietTrePhanPhatQua;
          if (chiTiet == null) {
            return _buildErrorState();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTreEmInfo(chiTiet),
                _buildQuaTangInfo(chiTiet),
                _buildSuKienInfo(chiTiet),
                _buildPhuHuynhInfo(chiTiet),
                _buildCapNhatSection(chiTiet),
                _buildLichSuSection(chiTiet),
                SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // THÔNG TIN TRẺ EM
  // ==========================================================================
  Widget _buildTreEmInfo(ChiTietTreEmPhanPhatQua chiTiet) {
    final baseUrl = 'http://10.0.2.2:5035';

    return Container(
      margin: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              if (chiTiet.anh != null && chiTiet.anh!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewerScreen(
                      imageUrl: '$baseUrl${chiTiet.anh}',
                      title: chiTiet.hoTen,
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: AppDimensions.avatarXL,
              height: AppDimensions.avatarXL,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimensions.borderThick,
                ),
              ),
              child: ClipOval(
                child: chiTiet.anh != null && chiTiet.anh!.isNotEmpty
                    ? Image.network(
                  '$baseUrl${chiTiet.anh}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      chiTiet.gioiTinh.toLowerCase() == 'nam'
                          ? Icons.boy
                          : Icons.girl,
                      size: AppDimensions.iconLG,
                      color: AppColors.primary,
                    );
                  },
                )
                    : Icon(
                  chiTiet.gioiTinh.toLowerCase() == 'nam'
                      ? Icons.boy
                      : Icons.girl,
                  size: AppDimensions.iconLG,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          SizedBox(width: AppDimensions.spacingMD),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chiTiet.hoTen,
                  style: AppTextStyles.headingMedium,
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                _buildInfoRow(Icons.cake, _formatDate(chiTiet.ngaySinh)),
                SizedBox(height: 2),
                _buildInfoRow(
                  chiTiet.gioiTinh.toLowerCase() == 'nam'
                      ? Icons.male
                      : Icons.female,
                  chiTiet.gioiTinh,
                ),
                if (chiTiet.tonGiao.isNotEmpty) ...[
                  SizedBox(height: 2),
                  _buildInfoRow(Icons.auto_awesome, chiTiet.tonGiao),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // THÔNG TIN QUÀ TẶNG
  // ==========================================================================
  Widget _buildQuaTangInfo(ChiTietTreEmPhanPhatQua chiTiet) {
    final baseUrl = 'http://10.0.2.2:5035';
    final trangThaiColor = chiTiet.trangThai == 'Đã nhận'
        ? AppColors.success
        : AppColors.warning;

    return Container(
      margin: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: trangThaiColor,
                size: AppDimensions.iconMD,
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: Text(
                  'Thông tin quà tặng',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              _buildTrangThaiChip(chiTiet.trangThai),
            ],
          ),

          Divider(
            height: AppDimensions.spacingLG,
            color: AppColors.divider,
          ),

          // Ảnh quà
          if (chiTiet.anhQua != null && chiTiet.anhQua!.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewerScreen(
                      imageUrl: '$baseUrl${chiTiet.anhQua}',
                      title: chiTiet.tenQua,
                    ),
                  ),
                );
              },
              child: Container(
                height: 200,
                margin: AppDimensions.paddingOnly(
                  bottom: AppDimensions.spacingSM,
                ),
                decoration: BoxDecoration(
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusMD,
                  ),
                  color: AppColors.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusMD,
                  ),
                  child: Image.network(
                    '$baseUrl${chiTiet.anhQua}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.card_giftcard,
                          size: AppDimensions.iconXXL,
                          color: AppColors.textDisabled,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // Tên quà
          _buildDetailRow('Tên quà', chiTiet.tenQua),
          _buildDetailRow('Mô tả', chiTiet.moTaQua),
          _buildDetailRow('Đơn giá', _formatCurrency(chiTiet.donGia)),
          _buildDetailRow('Số lượng nhận', '${chiTiet.soLuongNhan}'),
          _buildDetailRow('Đối tượng', chiTiet.doiTuongNhan),

          Divider(
            height: AppDimensions.spacingLG,
            color: AppColors.divider,
          ),

          // Số lượng tồn kho
          Row(
            children: [
              Expanded(
                child: _buildStockInfo(
                  'Tổng số lượng',
                  chiTiet.soLuongTong,
                  AppColors.info,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: _buildStockInfo(
                  'Còn lại',
                  chiTiet.soLuongConLai,
                  chiTiet.soLuongConLai > 0
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(String label, int value, Color color) {
    return Container(
      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
          SizedBox(height: AppDimensions.spacingXXS),
          Text(
            '$value',
            style: AppTextStyles.headingLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // THÔNG TIN SỰ KIỆN
  // ==========================================================================
  Widget _buildSuKienInfo(ChiTietTreEmPhanPhatQua chiTiet) {
    if (chiTiet.suKienID == 0) return const SizedBox();

    return Container(
      margin: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingSM,
      ),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: AppColors.info,
                size: AppDimensions.iconMD,
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Sự kiện liên quan',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),

          Divider(
            height: AppDimensions.spacingLG,
            color: AppColors.divider,
          ),

          _buildDetailRow('Tên sự kiện', chiTiet.tenSuKien),
          _buildDetailRow('Địa điểm', chiTiet.diaDiem),
          _buildDetailRow(
            'Thời gian',
            '${_formatDate(chiTiet.ngayBatDau)} - ${_formatDate(chiTiet.ngayKetThuc)}',
          ),

          SizedBox(height: AppDimensions.spacingSM),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChiTietSuKienScreen(
                      suKienId: chiTiet.suKienID,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Xem chi tiết sự kiện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: AppColors.textOnPrimary,
                padding: AppDimensions.paddingSymmetric(
                  vertical: AppDimensions.spacingSM,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // THÔNG TIN PHỤ HUYNH
  // ==========================================================================
  Widget _buildPhuHuynhInfo(ChiTietTreEmPhanPhatQua chiTiet) {
    if (chiTiet.danhSachPhuHuynh.isEmpty) return const SizedBox();

    return Container(
      margin: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: AppColors.secondary,
                size: AppDimensions.iconMD,
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Thông tin phụ huynh',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),

          Divider(
            height: AppDimensions.spacingLG,
            color: AppColors.divider,
          ),

          ...chiTiet.danhSachPhuHuynh.map((ph) => _buildPhuHuynhItem(ph)),
        ],
      ),
    );
  }

  Widget _buildPhuHuynhItem(ThongTinPhuHuynh ph) {
    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.spacingSM),
      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.chipPaddingH,
                  vertical: AppDimensions.chipPaddingV,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.chipRadius,
                  ),
                ),
                child: Text(
                  ph.moiQuanHe,
                  style: AppTextStyles.chip,
                ),
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: Text(
                  ph.hoTen,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingXS),
          _buildInfoRow(Icons.phone, ph.sdt),
          SizedBox(height: 2),
          _buildInfoRow(Icons.location_on, ph.diaChi),
          SizedBox(height: 2),
          _buildInfoRow(Icons.work, ph.ngheNghiep),
        ],
      ),
    );
  }

  // ==========================================================================
  // PHẦN CẬP NHẬT
  // ==========================================================================
  Widget _buildCapNhatSection(ChiTietTreEmPhanPhatQua chiTiet) {
    final canUpdate = chiTiet.trangThai != 'Đã nhận';

    return Container(
      margin: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                color: AppColors.primary,
                size: AppDimensions.iconMD,
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Cập nhật phân phát',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),

          Divider(
            height: AppDimensions.spacingLG,
            color: AppColors.divider,
          ),

          // Trạng thái
          Text(
            'Trạng thái *',
            style: AppTextStyles.labelMedium,
          ),
          SizedBox(height: AppDimensions.spacingXS),

          Row(
            children: [
              Expanded(
                child: _buildTrangThaiRadio(
                  'Đang tiến hành',
                  'Đang tiến hành',
                  canUpdate,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: _buildTrangThaiRadio(
                  'Đã nhận',
                  'Đã nhận',
                  canUpdate,
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacingMD),

          // Ngày phân phát
          Text(
            'Ngày phân phát *',
            style: AppTextStyles.labelMedium,
          ),
          SizedBox(height: AppDimensions.spacingXS),

          InkWell(
            onTap: canUpdate ? () => _chonNgayPhanPhat() : null,
            child: Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
              decoration: BoxDecoration(
                border: Border.all(
                  color: canUpdate ? AppColors.primary : AppColors.divider,
                ),
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusSM,
                ),
                color: canUpdate ? null : AppColors.surfaceVariant,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppDimensions.iconSM,
                    color: canUpdate
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                  SizedBox(width: AppDimensions.spacingSM),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: canUpdate
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppDimensions.spacingMD),

          // Ghi chú
          Text(
            'Ghi chú',
            style: AppTextStyles.labelMedium,
          ),
          SizedBox(height: AppDimensions.spacingXS),

          TextField(
            controller: _ghiChuController,
            enabled: canUpdate,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú...',
              border: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusSM,
                ),
              ),
              filled: !canUpdate,
              fillColor: !canUpdate ? AppColors.surfaceVariant : null,
            ),
          ),

          if (!canUpdate) ...[
            SizedBox(height: AppDimensions.spacingSM),
            Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
              decoration: BoxDecoration(
                color: AppColors.warningOverlay,
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusSM,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppColors.warning,
                    size: AppDimensions.iconSM,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Expanded(
                    child: Text(
                      'Không thể cập nhật quà đã được phát',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: AppDimensions.spacingMD),

          // Button cập nhật
          if (canUpdate)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _capNhat(chiTiet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: AppDimensions.paddingSymmetric(
                    vertical: AppDimensions.spacingMD,
                  ),
                ),
                child: const Text('Cập nhật'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrangThaiRadio(String label, String value, bool enabled) {
    return InkWell(
      onTap: enabled
          ? () {
        setState(() {
          _selectedTrangThai = value;
        });
      }
          : null,
      child: Container(
        padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedTrangThai == value && enabled
                ? AppColors.primary
                : AppColors.divider,
            width: _selectedTrangThai == value ? 2 : 1,
          ),
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
          color: !enabled ? AppColors.surfaceVariant : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedTrangThai,
              onChanged: enabled
                  ? (newValue) {
                setState(() {
                  _selectedTrangThai = newValue!;
                });
              }
                  : null,
            ),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // LỊCH SỬ PHÂN PHÁT
  // ==========================================================================
  Widget _buildLichSuSection(ChiTietTreEmPhanPhatQua chiTiet) {
    if (chiTiet.lichSuPhanPhatQua.isEmpty) return const SizedBox();

    return Container(
      margin: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppColors.accent,
                size: AppDimensions.iconMD,
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Lịch sử phân phát quà',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),

          Divider(
            height: AppDimensions.spacingLG,
            color: AppColors.divider,
          ),

          ...chiTiet.lichSuPhanPhatQua.map((ls) => _buildLichSuItem(ls)),
        ],
      ),
    );
  }

  Widget _buildLichSuItem(LichSuPhanPhatQua ls) {
    final baseUrl = 'http://10.0.2.2:5035';

    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.spacingSM),
      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
      ),
      child: Row(
        children: [
          // Ảnh quà
          if (ls.anhQua != null && ls.anhQua!.isNotEmpty)
            Container(
              width: 60,
              height: 60,
              margin: AppDimensions.paddingOnly(
                right: AppDimensions.spacingSM,
              ),
              decoration: BoxDecoration(
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusSM,
                ),
              ),
              child: ClipRRect(
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusSM,
                ),
                child: Image.network(
                  '$baseUrl${ls.anhQua}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.card_giftcard,
                      color: AppColors.textDisabled,
                    );
                  },
                ),
              ),
            ),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ls.tenQua,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                Text(
                  ls.tenSuKien,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: AppDimensions.iconXS - 2,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatDate(ls.ngayPhanPhat),
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(width: AppDimensions.spacingXS),
                    Text('×${ls.soLuongNhan}', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),

          // Trạng thái
          _buildTrangThaiChip(ls.trangThai),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXS,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: AppDimensions.spacingXXS),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: AppDimensions.paddingOnly(bottom: AppDimensions.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppDimensions.iconXXL,
            color: AppColors.error,
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(
            'Không tìm thấy thông tin',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================
  Future<void> _chonNgayPhanPhat() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _capNhat(ChiTietTreEmPhanPhatQua chiTiet) async {
    // Validate
    if (_selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày phân phát không được lớn hơn ngày hiện tại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm nếu chuyển sang "Đã nhận"
    if (_selectedTrangThai == 'Đã nhận' && chiTiet.trangThai != 'Đã nhận') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text(
            'Bạn có chắc chắn muốn cập nhật trạng thái "Đã nhận"? '
                'Sau khi cập nhật, không thể thay đổi lại.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    // Call API
    final provider = context.read<VolunteerProvider>();

    final success = await provider.capNhatPhanPhatQua(
      phanPhatID: chiTiet.phanPhatID,
      trangThai: _selectedTrangThai,
      ngayPhanPhat: DateFormat('yyyy-MM-dd').format(_selectedDate),
      ghiChu: _ghiChuController.text.trim().isEmpty
          ? null
          : _ghiChuController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật phân phát quà thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload data
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Cập nhật thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================
  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }
}