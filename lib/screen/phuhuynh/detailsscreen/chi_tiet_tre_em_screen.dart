import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screen/phuhuynh/detailsscreen/xem_anh_screen.dart';
import 'package:provider/provider.dart';

import '../../../models/tab_tai_khoan_ph.dart';
import '../../../providers/phu_huynh.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class ThongTinTreEmScreen extends StatefulWidget {
  final ThongTinTreEmChiTietResponse thongTin;

  const ThongTinTreEmScreen({Key? key, required this.thongTin})
      : super(key: key);

  @override
  State<ThongTinTreEmScreen> createState() => _ThongTinTreEmScreenState();
}

class _ThongTinTreEmScreenState extends State<ThongTinTreEmScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
  late TextEditingController _tonGiaoController;
  late TextEditingController _danTocController;
  late TextEditingController _quocTichController;
  late TextEditingController _tenLopController;
  late DateTime _ngaySinh;
  late String _gioiTinh;

  bool _isEditing = false;

  final baseUrl = 'http://10.0.2.2:5035';

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.thongTin.hoTen);
    _tonGiaoController = TextEditingController(text: widget.thongTin.tonGiao);
    _danTocController = TextEditingController(text: widget.thongTin.danToc);
    _quocTichController = TextEditingController(text: widget.thongTin.quocTich);
    _tenLopController = TextEditingController(text: widget.thongTin.tenLop);
    _gioiTinh = widget.thongTin.gioiTinh;

    try {
      _ngaySinh = DateFormat('dd/MM/yyyy').parse(widget.thongTin.ngaySinh);
    } catch (e) {
      _ngaySinh = DateTime.now();
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _tonGiaoController.dispose();
    _danTocController.dispose();
    _quocTichController.dispose();
    _tenLopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _gioiTinh.toLowerCase() == 'nam';
    final primaryColor = isMale ? const Color(0xFF3949AB) : const Color(0xFFD81B60);
    final overlayColor = isMale ? const Color(0x1A3949AB) : const Color(0x1AD81B60);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Thông tin con',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.elevationXS,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Chỉnh sửa',
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _luuThongTin,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppDimensions.screenPaddingH),
          children: [
            // Avatar section
            Center(
              child: GestureDetector(
                onTap: () {
                  if (widget.thongTin.anh != null &&
                      widget.thongTin.anh!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewerScreen(
                          imageUrl: '$baseUrl${widget.thongTin.anh}',
                          title: widget.thongTin.hoTen,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: AppDimensions.avatarXXL,
                  height: AppDimensions.avatarXXL,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.thongTin.anh != null &&
                        widget.thongTin.anh!.isNotEmpty
                        ? Image.network(
                      '$baseUrl${widget.thongTin.anh}',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, imageChild, loadingProgress) {
                        if (loadingProgress == null) return imageChild;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isMale ? Icons.boy_rounded : Icons.girl_rounded,
                          size: 64,
                          color: primaryColor,
                        );
                      },
                    )
                        : Icon(
                      isMale ? Icons.boy_rounded : Icons.girl_rounded,
                      size: 64,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.sectionGap),

            // Thông tin cá nhân
            _buildSectionTitle('Thông tin cá nhân', primaryColor),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: _hoTenController,
              label: 'Họ và tên',
              icon: Icons.person_outline_rounded,
              enabled: _isEditing,
              color: primaryColor,
              overlayColor: overlayColor,
              validator: (value) =>
              value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildDateField(
              label: 'Ngày sinh',
              value: _ngaySinh,
              enabled: _isEditing,
              color: primaryColor,
              overlayColor: overlayColor,
              onTap: () async {
                if (!_isEditing) return;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _ngaySinh,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  locale: const Locale('vi', 'VN'),
                );
                if (picked != null) {
                  setState(() => _ngaySinh = picked);
                }
              },
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildDropdownField(
              label: 'Giới tính',
              value: _gioiTinh,
              enabled: _isEditing,
              items: ['Nam', 'Nữ'],
              color: primaryColor,
              overlayColor: overlayColor,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _gioiTinh = value);
                }
              },
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: _tonGiaoController,
              label: 'Tôn giáo',
              icon: Icons.temple_buddhist_outlined,
              enabled: _isEditing,
              color: primaryColor,
              overlayColor: overlayColor,
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: _danTocController,
              label: 'Dân tộc',
              icon: Icons.people_outline_rounded,
              enabled: _isEditing,
              color: primaryColor,
              overlayColor: overlayColor,
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: _quocTichController,
              label: 'Quốc tịch',
              icon: Icons.flag_outlined,
              enabled: _isEditing,
              color: primaryColor,
              overlayColor: overlayColor,
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Thông tin học tập
            _buildSectionTitle('Thông tin học tập', primaryColor),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: TextEditingController(text: widget.thongTin.tenTruong),
              label: 'Trường',
              icon: Icons.school_outlined,
              enabled: false,
              color: primaryColor,
              overlayColor: overlayColor,
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: TextEditingController(text: widget.thongTin.capHoc),
              label: 'Cấp học',
              icon: Icons.class_outlined,
              enabled: false,
              color: primaryColor,
              overlayColor: overlayColor,
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _buildTextField(
              controller: _tenLopController,
              label: 'Lớp',
              icon: Icons.groups_outlined,
              enabled: _isEditing,
              color: primaryColor,
              overlayColor: overlayColor,
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Action buttons khi đang edit
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.buttonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                        side: BorderSide(
                          color: AppColors.textSecondary,
                          width: AppDimensions.borderMedium,
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingSM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _luuThongTin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.buttonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                        elevation: AppDimensions.elevationXS,
                      ),
                      child: Text(
                        'Lưu thay đổi',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          ),
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Text(
          title,
          style: AppTextStyles.headingMedium,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required Color color,
    required Color overlayColor,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: enabled ? color.withOpacity(0.3) : AppColors.divider,
          width: AppDimensions.borderThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: enabled ? overlayColor : AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius),
                bottomLeft: Radius.circular(AppDimensions.cardRadius),
              ),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconMD,
              color: enabled ? color : AppColors.textDisabled,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
              ),
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                validator: validator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required bool enabled,
    required Color color,
    required Color overlayColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: enabled ? color.withOpacity(0.3) : AppColors.divider,
            width: AppDimensions.borderThin,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: enabled ? overlayColor : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.cardRadius),
                  bottomLeft: Radius.circular(AppDimensions.cardRadius),
                ),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: AppDimensions.iconMD,
                color: enabled ? color : AppColors.textDisabled,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXXS),
                    Text(
                      DateFormat('dd/MM/yyyy').format(value),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required bool enabled,
    required List<String> items,
    required Color color,
    required Color overlayColor,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: enabled ? color.withOpacity(0.3) : AppColors.divider,
          width: AppDimensions.borderThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: enabled ? overlayColor : AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius),
                bottomLeft: Radius.circular(AppDimensions.cardRadius),
              ),
            ),
            child: Icon(
              Icons.wc_rounded,
              size: AppDimensions.iconMD,
              color: enabled ? color : AppColors.textDisabled,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
              ),
              child: DropdownButtonFormField<String>(
                value: value,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                items: items.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: enabled ? onChanged : null,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: enabled ? color : AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _luuThongTin() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = {
        'treEmID': widget.thongTin.treEmID,
        'hoTen': _hoTenController.text,
        'ngaySinh': DateFormat('yyyy-MM-dd').format(_ngaySinh),
        'gioiTinh': _gioiTinh,
        'tonGiao': _tonGiaoController.text,
        'danToc': _danTocController.text,
        'quocTich': _quocTichController.text,
        'tenLop': _tenLopController.text,
      };

      await context.read<PhuHuynhProvider>().capNhatThongTinTreEm(data);

      Navigator.pop(context);
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cập nhật thành công',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          title: Text('Lỗi', style: AppTextStyles.headingMedium),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _luuThongTin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                ),
              ),
              child: Text(
                'Thử lại',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}