import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/tab_tai_khoan_ph.dart';
import '../../providers/phu_huynh.dart';
import '../auth/auth.dart';
import 'danh_sach_con_screen.dart';
import 'danh_sach_phu_huynh_screen.dart';
import 'doi_mat_khau_dialog.dart';

class TabTaiKhoanScreen extends StatelessWidget {
  const TabTaiKhoanScreen({Key? key}) : super(key: key);

  final baseUrl = 'http://10.0.2.2:5035';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.thongTinTaiKhoan == null) {
            // Load data nếu chưa có
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadThongTinTaiKhoan();
            });
            return const Center(child: CircularProgressIndicator());
          }

          final info = provider.thongTinTaiKhoan!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header với avatar
                _buildProfileHeader(context, info, provider),
                const SizedBox(height: 8),
                // Menu options
                _buildMenuSection(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context,
      ThongTinTaiKhoanResponse info,
      PhuHuynhProvider provider,
      ) {
    return Container(
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
          // Avatar
          GestureDetector(
            onTap: () => _showAvatarOptions(context, provider),
            child: Stack(
              children: [
                _buildAvatar(info.anh, info.hoTen),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
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
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            info.hoTen,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.sdt,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? anh, String hoTen) {
    if (anh != null && anh.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage("$baseUrl$anh"),
        backgroundColor: Colors.white,
      );
    }

    // Avatar mặc định với chữ cái đầu
    final initial = hoTen.isNotEmpty ? hoTen[0].toUpperCase() : 'U';
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final colorIndex = hoTen.codeUnitAt(0) % colors.length;

    return CircleAvatar(
      radius: 60,
      backgroundColor: colors[colorIndex].shade100,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: colors[colorIndex].shade700,
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, PhuHuynhProvider provider) {
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
                  _pickImage(context, ImageSource.camera, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery, provider);
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

  Future<void> _pickImage(
      BuildContext context,
      ImageSource source,
      PhuHuynhProvider provider,
      ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await provider.uploadAnhTaiKhoan(File(pickedFile.path));
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh thành công')),
        );
      } catch (e) {
        Navigator.pop(context); // Close loading
        _showErrorDialog(context, 'Không thể tải ảnh lên. Vui lòng thử lại.');
      }
    }
  }

  Widget _buildMenuSection(BuildContext context, PhuHuynhProvider provider) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'Thông tin phụ huynh',
          subtitle: 'Xem và chỉnh sửa thông tin',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DanhSachPhuHuynhScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.child_care,
          title: 'Cập nhật thông tin con em',
          subtitle: 'Chỉnh sửa thông tin các con',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DanhSachConEmScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.lock,
          title: 'Đổi mật khẩu',
          subtitle: 'Thay đổi mật khẩu đăng nhập',
          color: Colors.orange,
          onTap: () => _showDoiMatKhauDialog(context, provider),
        ),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Đăng xuất',
          subtitle: 'Thoát khỏi tài khoản',
          color: Colors.red,
          onTap: () => _showDangXuatDialog(context, provider),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showDoiMatKhauDialog(BuildContext context, PhuHuynhProvider provider) {
    showDialog(
      context: context,
      builder: (context) => const DoiMatKhauDialog(),
    );
  }

  void _showDangXuatDialog(BuildContext context, PhuHuynhProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                const Center(child: CircularProgressIndicator()),
              );

              try {
                await provider.dangXuat();
                await _clearUserData(context);

                Navigator.pop(context); // Close loading

                // Navigate to login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              } catch (e) {
                Navigator.pop(context); // Close loading
                _showErrorDialog(context, 'Lỗi đăng xuất. Vui lòng thử lại.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearUserData(BuildContext context) async {
    // TODO: Clear SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // Clear provider state
    context.read<PhuHuynhProvider>().clearAll();
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry logic can be added here
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}