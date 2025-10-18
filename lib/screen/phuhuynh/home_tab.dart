import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/thong_bao_tab.dart';
import '../../services/phu_huynh.dart';
import '../../widgets/info_card.dart';

class ParentHomeTab extends StatelessWidget {
  final Map<String, dynamic> user;
  final ParentService _service = ParentService();

  ParentHomeTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = _service.getChildren(user['userId']);
    final firstChild = children.isNotEmpty ? children[0] : null;
    final unreadCount = _service.getNotifications().where((t) => !t['daDoc']).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentNotificationTab(user: user),
                    ),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (firstChild != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(firstChild['avatar'],
                        style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstChild['hoTen'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        firstChild['lop'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            InfoCard(
              title: 'Thông tin học tập mới nhất',
              icon: Icons.school,
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phiếu điểm HK1 2024-2025',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Điểm TB: 8.5 - Xếp loại: Giỏi'),
                  const Text('Hạnh kiểm: Tốt'),
                  const SizedBox(height: 8),
                  Text('Cập nhật: 15/12/2024',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Hỗ trợ đã nhận (tháng này)',
              icon: Icons.card_giftcard,
              color: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Học bổng khuyến học học kỳ 1',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Ngày cấp: 01/10/2024'),
                  const SizedBox(height: 8),
                  Text('Người chịu trách nhiệm: Ban điều hành khu phố',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Sự kiện sắp tới',
              icon: Icons.event,
              color: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Khám sức khỏe định kỳ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14),
                      const SizedBox(width: 4),
                      const Text('20/11/2024'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      const Text('Trạm Y tế Phường 10'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}