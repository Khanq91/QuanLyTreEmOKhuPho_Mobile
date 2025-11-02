import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tab_con_toi.dart';

class ChiTietPhieuHocTapScreen extends StatelessWidget {
  final PhieuHocTapInfo phieu;

  const ChiTietPhieuHocTapScreen({Key? key, required this.phieu})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phiếu học tập'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      phieu.tenLop,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phieu.tenTruong,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Điểm số
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Điểm trung bình',
                    phieu.diemTrungBinh.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Xếp loại',
                    phieu.xepLoai,
                    Icons.emoji_events,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Hạnh kiểm',
              phieu.hanhKiem,
              Icons.favorite,
              Colors.red,
              fullWidth: true,
            ),
            const SizedBox(height: 20),
            // Nhận xét
            const Text(
              'Nhận xét của giáo viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                phieu.nhanXet.isNotEmpty
                    ? phieu.nhanXet
                    : 'Chưa có nhận xét',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            // Ngày cập nhật
            Row(
              children: [
                Icon(Icons.update, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Cập nhật ngày: ${_formatDate(phieu.ngayCapNhat)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String label,
      String value,
      IconData icon,
      Color color, {
        bool fullWidth = false,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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