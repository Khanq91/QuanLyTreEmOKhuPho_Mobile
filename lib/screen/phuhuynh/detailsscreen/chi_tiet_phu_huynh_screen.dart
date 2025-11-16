import 'dart:io';
import 'package:mobile/screen/phuhuynh/detailsscreen/xem_anh_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../models/tab_tai_khoan_ph.dart';
import '../../../providers/phu_huynh.dart';

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
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin phụ huynh'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: hasAvatar
                                ? Image.network(
                              '$baseUrl${widget.phuHuynh.anh}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person,
                                    size: 60, color: Colors.grey.shade400);
                              },
                            )
                                : Icon(Icons.person,
                                size: 60, color: Colors.grey.shade400),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.phuHuynh.hoTen,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Mối quan hệ (nếu có)
            if (widget.phuHuynh.danhSachMoiQuanHe.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.family_restroom,
                            color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Mối quan hệ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...widget.phuHuynh.danhSachMoiQuanHe.map((mqh) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${mqh.moiQuanHe} ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    const TextSpan(text: 'của '),
                                    TextSpan(
                                      text: mqh.tenTreEm,
                                      style: const TextStyle(
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
              padding: const EdgeInsets.all(16),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _sdtController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (value.length < 10) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _ngaySinhController,
                      label: 'Ngày sinh',
                      icon: Icons.cake,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _diaChiController,
                      label: 'Địa chỉ',
                      icon: Icons.home,
                      enabled: _isEditing,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ngheNghiepController,
                      label: 'Nghề nghiệp',
                      icon: Icons.work,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _tonGiaoController,
                      label: 'Tôn giáo',
                      icon: Icons.church,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _danTocController,
                      label: 'Dân tộc',
                      icon: Icons.people,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _quocTichController,
                      label: 'Quốc tịch',
                      icon: Icons.flag,
                      enabled: _isEditing,
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
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
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      onTap: enabled
          ? () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _parseDate(controller.text) ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          controller.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: enabled ? const Icon(Icons.calendar_today) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

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

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Back to list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công')),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
}