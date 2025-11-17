// File: screens/tinh_nguyen_vien/detailsscreen/chinh_sua_thong_tin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../../../models/tab_tai_khoan_tnv.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import '../../other/app_text.dart';

class ChinhSuaThongTinScreen extends StatefulWidget {
  const ChinhSuaThongTinScreen({Key? key}) : super(key: key);

  @override
  State<ChinhSuaThongTinScreen> createState() => _ChinhSuaThongTinScreenState();
}

class _ChinhSuaThongTinScreenState extends State<ChinhSuaThongTinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _sdtController = TextEditingController();
  final _emailController = TextEditingController();
  final _ngaySinhController = TextEditingController();
  final _tenKhuPhoMoiController = TextEditingController();
  final _diaChiKhuPhoController = TextEditingController();
  final _quanHuyenController = TextEditingController();
  final _thanhPhoController = TextEditingController();

  DateTime? _selectedNgaySinh;
  int? _selectedKhuPhoId;
  bool _isEditing = false;
  bool _hasChanges = false;
  bool _isKhuPhoKhac = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<VolunteerProvider>();

    try {
      await Future.wait([
        provider.loadProfile(),
        provider.loadDanhSachKhuPho(),
      ]);

      if (provider.profile != null) {
        _initializeData(provider.profile!);
      }
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

  void _initializeData(TinhNguyenVienProfile profile) {
    _hoTenController.text = profile.hoTen;
    _sdtController.text = profile.sdt;
    _emailController.text = profile.email;
    _selectedNgaySinh = profile.ngaySinh;
    if (_selectedNgaySinh != null) {
      _ngaySinhController.text = DateFormat('dd/MM/yyyy').format(_selectedNgaySinh!);
    }

    // Tìm khu phố hiện tại trong danh sách
    final provider = context.read<VolunteerProvider>();
    final khuPhoHienTai = provider.danhSachKhuPho.firstWhere(
          (kp) => kp.tenKhuPho == profile.tenKhuPho,
      orElse: () => provider.danhSachKhuPho.first,
    );
    _selectedKhuPhoId = khuPhoHienTai.khuPhoId;
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _sdtController.dispose();
    _emailController.dispose();
    _ngaySinhController.dispose();
    _tenKhuPhoMoiController.dispose();
    _diaChiKhuPhoController.dispose();
    _quanHuyenController.dispose();
    _thanhPhoController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận thoát'),
        content: Text('Bạn có thay đổi chưa lưu. Bạn có muốn thoát không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Ở lại'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Thoát'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedNgaySinh ?? DateTime(2000),
      firstDate: DateTime(1924),
      lastDate: DateTime.now().subtract(Duration(days: 365 * 15)), // Tối thiểu 15 tuổi
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedNgaySinh = date;
        _ngaySinhController.text = DateFormat('dd/MM/yyyy').format(date);
        _onFieldChanged();
      });
    }
  }

  Future<void> _showConfirmDialog() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận cập nhật'),
        content: Text('Bạn có chắc chắn muốn cập nhật thông tin tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _handleSave();
    }
  }

  Future<void> _handleSave() async {
    try {
      final request = UpdateProfileRequest(
        hoTen: _hoTenController.text.trim(),
        sdt: _sdtController.text.trim(),
        email: _emailController.text.trim(),
        ngaySinh: _selectedNgaySinh,
        khuPhoId: _isKhuPhoKhac ? null : _selectedKhuPhoId,
        tenKhuPhoMoi: _isKhuPhoKhac ? _tenKhuPhoMoiController.text.trim() : null,
        diaChiKhuPho: _isKhuPhoKhac ? _diaChiKhuPhoController.text.trim() : null,
        quanHuyen: _isKhuPhoKhac ? _quanHuyenController.text.trim() : null,
        thanhPho: _isKhuPhoKhac ? _thanhPhoController.text.trim() : null,
      );

      await context.read<VolunteerProvider>().capNhatThongTinTaiKhoan(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Trả về true để reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin tài khoản',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textOnPrimary),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: IconThemeData(color: AppColors.textOnPrimary),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
                tooltip: 'Chỉnh sửa',
              ),
          ],
        ),
        body: Consumer<VolunteerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || provider.isLoadingKhuPho) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (provider.profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: AppDimensions.spacingMD),
                    Text('Không tải được thông tin', style: AppTextStyles.bodyLarge),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Thông tin cơ bản',
                      children: [
                        _buildTextField(
                          controller: _hoTenController,
                          label: 'Họ tên',
                          icon: Icons.person,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập họ tên';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.spacingMD),
                        _buildTextField(
                          controller: _sdtController,
                          label: 'Số điện thoại',
                          icon: Icons.phone,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.spacingMD),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.spacingMD),
                        _buildTextField(
                          controller: _ngaySinhController,
                          label: 'Ngày sinh',
                          icon: Icons.cake,
                          enabled: _isEditing,
                          readOnly: true,
                          onTap: _isEditing ? _selectDate : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn ngày sinh';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingXL),
                    _buildSection(
                      title: 'Địa chỉ',
                      children: [
                        _buildDropdown(
                          label: 'Khu phố',
                          value: _selectedKhuPhoId,
                          items: [
                            ...provider.danhSachKhuPho.map((kp) => DropdownMenuItem(
                              value: kp.khuPhoId,
                              child: Text(kp.tenKhuPho),
                            )),
                            DropdownMenuItem(
                              value: -1,
                              child: Text('Khác (nhập mới)'),
                            ),
                          ],
                          onChanged: _isEditing
                              ? (value) {
                            setState(() {
                              if (value == -1) {
                                _isKhuPhoKhac = true;
                                _selectedKhuPhoId = null;
                              } else {
                                _isKhuPhoKhac = false;
                                _selectedKhuPhoId = value;

                                // Auto-fill địa chỉ
                                final khuPho = provider.danhSachKhuPho
                                    .firstWhere((kp) => kp.khuPhoId == value);
                                _diaChiKhuPhoController.text = khuPho.diaChi ?? '';
                                _quanHuyenController.text = khuPho.quanHuyen ?? '';
                                _thanhPhoController.text = khuPho.thanhPho ?? '';
                              }
                              _onFieldChanged();
                            });
                          }
                              : null,
                          enabled: _isEditing,
                        ),
                        if (_isKhuPhoKhac) ...[
                          SizedBox(height: AppDimensions.spacingMD),
                          _buildTextField(
                            controller: _tenKhuPhoMoiController,
                            label: 'Tên khu phố mới',
                            icon: Icons.location_on,
                            enabled: _isEditing,
                            validator: (value) {
                              if (_isKhuPhoKhac && (value == null || value.trim().isEmpty)) {
                                return 'Vui lòng nhập tên khu phố';
                              }
                              return null;
                            },
                          ),
                        ],
                        SizedBox(height: AppDimensions.spacingMD),
                        _buildTextField(
                          controller: _diaChiKhuPhoController,
                          label: 'Địa chỉ khu phố',
                          icon: Icons.home,
                          enabled: _isEditing && _isKhuPhoKhac,
                        ),
                        SizedBox(height: AppDimensions.spacingMD),
                        _buildTextField(
                          controller: _quanHuyenController,
                          label: 'Quận/Huyện',
                          icon: Icons.location_city,
                          enabled: _isEditing && _isKhuPhoKhac,
                        ),
                        SizedBox(height: AppDimensions.spacingMD),
                        _buildTextField(
                          controller: _thanhPhoController,
                          label: 'Thành phố',
                          icon: Icons.location_city,
                          enabled: _isEditing && _isKhuPhoKhac,
                        ),
                      ],
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: AppDimensions.spacingXL),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final shouldPop = await _onWillPop();
                                if (shouldPop && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: AppDimensions.paddingSymmetric(
                                    vertical: AppDimensions.spacingSM),
                                side: BorderSide(color: AppColors.textSecondary),
                              ),
                              child: Text('Hủy'),
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingMD),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _hasChanges ? _showConfirmDialog : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: AppDimensions.paddingSymmetric(
                                    vertical: AppDimensions.spacingSM),
                              ),
                              child: Text('Lưu thay đổi'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: AppDimensions.spacingXL),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => _onFieldChanged(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.background,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?>? onChanged,
    required bool enabled,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.location_on,
            color: enabled ? AppColors.primary : AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.background,
      ),
    );
  }
}