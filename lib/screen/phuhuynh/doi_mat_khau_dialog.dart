import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/phu_huynh.dart';

class DoiMatKhauDialog extends StatefulWidget {
  const DoiMatKhauDialog({Key? key}) : super(key: key);

  @override
  State<DoiMatKhauDialog> createState() => _DoiMatKhauDialogState();
}

class _DoiMatKhauDialogState extends State<DoiMatKhauDialog> {
  final _formKey = GlobalKey<FormState>();
  final _matKhauCuController = TextEditingController();
  final _matKhauMoiController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _matKhauCuController.dispose();
    _matKhauMoiController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _matKhauCuController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu cũ',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu cũ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _matKhauMoiController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _xacNhanMatKhauController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_clock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _matKhauMoiController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _doiMatKhau,
          child: const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }

  Future<void> _doiMatKhau() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await context.read<PhuHuynhProvider>().doiMatKhau(
        _matKhauCuController.text,
        _matKhauMoiController.text,
      );

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading

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
                _doiMatKhau(); // Retry
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
  }
}