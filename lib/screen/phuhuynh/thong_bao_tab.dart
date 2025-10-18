import 'package:flutter/material.dart';
import '../../data/data_repository.dart';
import '../../services/phu_huynh.dart';

class ParentNotificationTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const ParentNotificationTab({Key? key, required this.user}) : super(key: key);

  @override
  State<ParentNotificationTab> createState() => _ParentNotificationTabState();
}

class _ParentNotificationTabState extends State<ParentNotificationTab> {
  String _filter = 'Tất cả';
  final ParentService _service = ParentService();

  @override
  Widget build(BuildContext context) {
    var filteredNotifications = _service.getNotifications();
    if (_filter != 'Tất cả') {
      filteredNotifications = filteredNotifications
          .where((t) => t['loai'] == _filter)
          .toList();
    }

    final unreadCount = filteredNotifications.where((t) => !t['daDoc']).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notif in DataRepository().thongBao) {
                    notif['daDoc'] = true;
                  }
                });
              },
              child: const Text('Đánh dấu đã đọc tất cả',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', filteredNotifications.length),
                  _buildFilterChip(
                      'Học tập',
                      _service.getNotifications()
                          .where((t) => t['loai'] == 'Học tập')
                          .length),
                  _buildFilterChip(
                      'Sự kiện',
                      _service.getNotifications()
                          .where((t) => t['loai'] == 'Sự kiện')
                          .length),
                  _buildFilterChip(
                      'Hỗ trợ',
                      _service.getNotifications()
                          .where((t) => t['loai'] == 'Hỗ trợ')
                          .length),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredNotifications.isEmpty
                ? const Center(child: Text('Không có thông báo'))
                : ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notif = filteredNotifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notif['daDoc']
                        ? Colors.grey[300]
                        : Colors.blue[100],
                    child: Icon(
                      _getIconForType(notif['loai']),
                      color:
                      notif['daDoc'] ? Colors.grey : Colors.blue,
                    ),
                  ),
                  title: Text(
                    notif['noiDung'],
                    style: TextStyle(
                      fontWeight: notif['daDoc']
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif['ngayThongBao']),
                  trailing: !notif['daDoc']
                      ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                      : null,
                  onTap: () {
                    setState(() {
                      notif['daDoc'] = true;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _filter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filter = label);
        },
        selectedColor: Colors.blue[100],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Học tập':
        return Icons.school;
      case 'Sự kiện':
        return Icons.event;
      case 'Hỗ trợ':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }
}