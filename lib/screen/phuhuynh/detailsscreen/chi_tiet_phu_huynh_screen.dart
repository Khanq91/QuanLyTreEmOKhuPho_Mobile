import 'dart:io';
import 'package:mobile/screen/other/xem_anh_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../models/tab_tai_khoan_ph.dart';
import '../../../providers/phu_huynh.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class ChiTietPhuHuynhScreen extends StatefulWidget {
  final PhuHuynhVoiMoiQuanHe phuHuynh;

  const ChiTietPhuHuynhScreen({Key? key, required this.phuHuynh})
      : super(key: key);

  @override
  State<ChiTietPhuHuynhScreen> createState() => _ChiTietPhuHuynhScreenState();
}

class _ChiTietPhuHuynhScreenState extends State<ChiTietPhuHuynhScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
  late TextEditingController _sdtController;
  late TextEditingController _diaChiController;
  late TextEditingController _ngheNghiepController;
  late TextEditingController _ngaySinhController;
  late TextEditingController _tonGiaoController;
  late TextEditingController _danTocController;
  late TextEditingController _quocTichController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.phuHuynh.hoTen);
    _sdtController = TextEditingController(text: widget.phuHuynh.sdt);
    _diaChiController = TextEditingController(text: widget.phuHuynh.diaChi);
    _ngheNghiepController =
        TextEditingController(text: widget.phuHuynh.ngheNghiep);
    _ngaySinhController = TextEditingController(text: widget.phuHuynh.ngaySinh);
    _tonGiaoController = TextEditingController(text: widget.phuHuynh.tonGiao);
    _danTocController = TextEditingController(text: widget.phuHuynh.danToc);
    _quocTichController = TextEditingController(text: widget.phuHuynh.quocTich);
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _sdtController.dispose();
    _diaChiController.dispose();
    _ngheNghiepController.dispose();
    _ngaySinhController.dispose();
    _tonGiaoController.dispose();
    _danTocController.dispose();
    _quocTichController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseUrl = 'http://10.0.2.2:5035';
    final hasAvatar = widget.phuHuynh.anh.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin phụ huynh',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.appBarElevation,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: AppDimensions.iconMD),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, size: AppDimensions.iconMD),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với avatar - Solid color
            Container(
              width: double.infinity,
              padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isEditing
                        ? () => _showAvatarOptions(context)
                        : (hasAvatar
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerScreen(
                            imageUrl: '$baseUrl${widget.phuHuynh.anh}',
                            title: widget.phuHuynh.hoTen,
                          ),
                        ),
                      );
                    }
                        : null),
                    child: Stack(
                      children: [
                        Container(
                          width: AppDimensions.avatarXXL,
                          height: AppDimensions.avatarXXL,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: AppDimensions.borderExtraThick,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: hasAvatar
                                ? Image.network(
                              '$baseUrl${widget.phuHuynh.anh}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: AppDimensions.iconXL,
                                  color: AppColors.textDisabled,
                                );
                              },
                            )
                                : Icon(
                              Icons.person,
                              size: AppDimensions.iconXL,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: AppDimensions.iconSM,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingMD),
                  Text(
                    widget.phuHuynh.hoTen,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Mối quan hệ (nếu có)
            if (widget.phuHuynh.danhSachMoiQuanHe.isNotEmpty)
              Container(
                margin: AppDimensions.paddingAll(AppDimensions.spacingMD),
                padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
                decoration: BoxDecoration(
                  color: AppColors.successOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.withBorder(AppColors.success),
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.family_restroom,
                          color: AppColors.success,
                          size: AppDimensions.iconMD,
                        ),
                        SizedBox(width: AppDimensions.spacingXS),
                        Text(
                          'Mối quan hệ',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingSM),
                    ...widget.phuHuynh.danhSachMoiQuanHe.map((mqh) {
                      return Padding(
                        padding: AppDimensions.paddingOnly(
                          bottom: AppDimensions.spacingXS,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: AppDimensions.paddingOnly(
                                top: AppDimensions.spacingXS,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: AppDimensions.spacingSM),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: '${mqh.moiQuanHe} ',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const TextSpan(text: 'của '),
                                    TextSpan(
                                      text: mqh.tenTreEm,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            // Form thông tin
            Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _hoTenController,
                      label: 'Họ và tên',
                      icon: Icons.person,
                      enabled: _isEditing,
                      helperText: 'Họ và tên đầy đủ của phụ huynh',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        if (value.length < 3) {
                          return 'Họ tên phải có ít nhất 3 ký tự';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildTextField(
                      controller: _sdtController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      helperText: 'Số điện thoại liên hệ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (value.length < 10) {
                          return 'Số điện thoại phải có ít nhất 10 số';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Số điện thoại chỉ chứa chữ số';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildDateField(
                      controller: _ngaySinhController,
                      label: 'Ngày sinh',
                      icon: Icons.cake,
                      enabled: _isEditing,
                      helperText: 'Định dạng: dd/MM/yyyy',
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildTextField(
                      controller: _diaChiController,
                      label: 'Địa chỉ',
                      icon: Icons.home,
                      enabled: _isEditing,
                      maxLines: 2,
                      helperText: 'Địa chỉ thường trú hoặc tạm trú',
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildTextField(
                      controller: _ngheNghiepController,
                      label: 'Nghề nghiệp',
                      icon: Icons.work,
                      enabled: _isEditing,
                      helperText: 'Công việc hiện tại',
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildTextField(
                      controller: _tonGiaoController,
                      label: 'Tôn giáo',
                      icon: Icons.church,
                      enabled: _isEditing,
                      helperText: 'Tôn giáo (nếu có)',
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildTextField(
                      controller: _danTocController,
                      label: 'Dân tộc',
                      icon: Icons.people,
                      enabled: _isEditing,
                      helperText: 'Dân tộc',
                    ),
                    SizedBox(height: AppDimensions.formFieldGap),
                    _buildTextField(
                      controller: _quocTichController,
                      label: 'Quốc tịch',
                      icon: Icons.flag,
                      enabled: _isEditing,
                      helperText: 'Quốc tịch hiện tại',
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: AppDimensions.spacingXXL),
                      _buildSaveButton(),
                    ],
                    SizedBox(height: AppDimensions.spacingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: enabled
            ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
            : AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
        helperText: enabled ? helperText : null,
        helperStyle: AppTextStyles.caption,
        helperMaxLines: 2,
        prefixIcon: Icon(
          icon,
          size: AppDimensions.iconMD,
          color: enabled ? AppColors.primary : AppColors.textDisabled,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderMedium,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        filled: !enabled,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
        contentPadding: AppDimensions.paddingSymmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingSM,
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      style: AppTextStyles.bodyMedium,
      onTap: enabled
          ? () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _parseDate(controller.text) ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: AppColors.textOnPrimary,
                  surface: AppColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: enabled
            ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
            : AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
        helperText: enabled ? helperText : null,
        helperStyle: AppTextStyles.caption,
        prefixIcon: Icon(
          icon,
          size: AppDimensions.iconMD,
          color: enabled ? AppColors.primary : AppColors.textDisabled,
        ),
        suffixIcon: enabled
            ? Icon(
          Icons.calendar_today,
          size: AppDimensions.iconSM,
          color: AppColors.primary,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderMedium,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        filled: !enabled,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
        contentPadding: AppDimensions.paddingSymmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingSM,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: AppDimensions.buttonHeightMD,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textDisabled,
          elevation: AppDimensions.elevationNone,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
          ),
          padding: AppDimensions.paddingSymmetric(
            vertical: AppDimensions.buttonPaddingV,
          ),
        ),
        child: _isSaving
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppDimensions.iconSM,
              height: AppDimensions.iconSM,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            ),
            SizedBox(width: AppDimensions.spacingXS),
            Text(
              'Đang lưu...',
              style: AppTextStyles.button,
            ),
          ],
        )
            : Text(
          'Lưu thay đổi',
          style: AppTextStyles.button,
        ),
      ),
    );
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Hủy'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await context
            .read<PhuHuynhProvider>()
            .uploadAnhPhuHuynhCuThe(widget.phuHuynh.phuHuynhID, File(pickedFile.path));
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh thành công')),
        );
        setState(() {}); // Refresh UI
      } catch (e) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<PhuHuynhProvider>().capNhatPhuHuynh({
        'phuHuynhID': widget.phuHuynh.phuHuynhID,
        'hoTen': _hoTenController.text,
        'sdt': _sdtController.text,
        'diaChi': _diaChiController.text,
        'ngheNghiep': _ngheNghiepController.text,
        'ngaySinh': _ngaySinhController.text,
        'tonGiao': _tonGiaoController.text,
        'danToc': _danTocController.text,
        'quocTich': _quocTichController.text,
      });

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context); // Back to list
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
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
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
}