import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screen/phuhuynh/xem_anh_screen.dart';
import 'package:provider/provider.dart';
import '../../models/tab_tai_khoan_ph.dart';
import '../../providers/phu_huynh.dart';

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
    final iconColor = isMale ? Colors.blue.shade700 : Colors.pink.shade700;
    final bgColor = isMale ? Colors.blue.shade100 : Colors.pink.shade100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin con'),
        backgroundColor: isMale ? Colors.blue : Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _luuThongTin,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔥 Avatar section (ảnh thật hoặc icon)
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 3),
                  ),
                  child: ClipOval(
                    child: widget.thongTin.anh != null &&
                        widget.thongTin.anh!.isNotEmpty
                        ? Image.network(
                      '$baseUrl${widget.thongTin.anh}',
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (context, imageChild, loadingProgress) {
                        if (loadingProgress == null) return imageChild;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress
                                .cumulativeBytesLoaded /
                                loadingProgress
                                    .expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Nếu load ảnh lỗi → icon giới tính
                        return Icon(
                          isMale ? Icons.boy : Icons.girl,
                          size: 60,
                          color: iconColor,
                        );
                      },
                    )
                        : Icon(
                      isMale ? Icons.boy : Icons.girl,
                      size: 60,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔸 Các trường thông tin
            _buildTextField(
              controller: _hoTenController,
              label: 'Họ và tên',
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) =>
              value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Ngày sinh',
              value: _ngaySinh,
              enabled: _isEditing,
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
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Giới tính',
              value: _gioiTinh,
              enabled: _isEditing,
              items: ['Nam', 'Nữ'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _gioiTinh = value);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _tonGiaoController,
              label: 'Tôn giáo',
              icon: Icons.temple_buddhist,
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
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Thông tin học tập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller:
              TextEditingController(text: widget.thongTin.tenTruong),
              label: 'Trường',
              icon: Icons.school,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: TextEditingController(text: widget.thongTin.capHoc),
              label: 'Cấp học',
              icon: Icons.class_,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _tenLopController,
              label: 'Lớp',
              icon: Icons.groups,
              enabled: _isEditing,
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _luuThongTin,
                      child: const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // Các hàm build field giữ nguyên
  // -------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(value)),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required bool enabled,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.wc),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  // -------------------------------
  // Hàm lưu thông tin (giữ nguyên logic)
  // -------------------------------
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
        const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi'),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _luuThongTin();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
  }
}
