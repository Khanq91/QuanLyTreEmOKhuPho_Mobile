import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screen/phuhuynh/xem_anh_screen.dart';
import '../../models/tab_con_toi.dart';

class ChiTietTreEmScreen extends StatelessWidget {
  final TreEmBasicInfo child;

  const ChiTietTreEmScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMale = child.gioiTinh.toLowerCase() == 'nam';
    final avatarColor = isMale ? Colors.blue.shade100 : Colors.pink.shade100;
    final iconColor = isMale ? Colors.blue.shade700 : Colors.pink.shade700;
    final baseUrl = 'http://10.0.2.2:5035';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chi tiết'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                  colors: isMale
                      ? [Colors.blue.shade400, Colors.blue.shade600]
                      : [Colors.pink.shade400, Colors.pink.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar: Ảnh thật hoặc icon theo giới tính
                  GestureDetector(
                    onTap: () {
                      if (child.anh != null && child.anh!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerScreen(
                              imageUrl: '$baseUrl${child.anh}',
                              title: child.hoTen,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: child.anh != null && child.anh!.isNotEmpty
                            ? Image.network(
                          '$baseUrl${child.anh}',
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
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Nếu load ảnh lỗi → hiển thị icon giới tính
                            return Icon(
                              isMale ? Icons.boy : Icons.girl,
                              size: 80,
                              color: iconColor,
                            );
                          },
                        )
                            : Icon(
                          isMale ? Icons.boy : Icons.girl,
                          size: 80,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    child.hoTen,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${child.treEmID}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],

              ),
            ),
            // Thông tin chi tiết
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin cơ bản'),
                  _buildInfoRow('Họ và tên', child.hoTen),
                  _buildInfoRow('Ngày sinh', _formatDate(child.ngaySinh)),
                  _buildInfoRow('Giới tính', child.gioiTinh),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Thông tin học tập'),
                  _buildInfoRow('Trường', child.tenTruong),
                  _buildInfoRow('Cấp học', child.capHoc),
                  const SizedBox(height: 32),
                  // Note về API
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.orange.shade50,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.orange.shade200),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.info_outline, color: Colors.orange.shade700),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: Text(
                  //           'Thông tin chi tiết đầy đủ sẽ hiển thị khi có API',
                  //           style: TextStyle(
                  //             fontSize: 13,
                  //             color: Colors.orange.shade900,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }
}