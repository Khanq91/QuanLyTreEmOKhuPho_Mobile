import 'package:flutter/material.dart';

import '../../services/phu_huynh.dart';

class ParentChildrenTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const ParentChildrenTab({Key? key, required this.user}) : super(key: key);

  @override
  State<ParentChildrenTab> createState() => _ParentChildrenTabState();
}
class _ParentChildrenTabState extends State<ParentChildrenTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChildIndex = 0;
  final ParentService _service = ParentService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final children = _service.getChildren(widget.user['userId']);

    if (children.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Con tôi')),
        body: const Center(child: Text('Chưa có thông tin con em')),
      );
    }

    final selectedChild = children[_selectedChildIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Con tôi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Học tập'),
            Tab(text: 'Hỗ trợ'),
            Tab(text: 'Sự kiện'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (children.length > 1)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  final isSelected = index == _selectedChildIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedChildIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[100] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(child['avatar'],
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 0),
                          Text(child['hoTen'].split(' ').last,
                              style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(selectedChild['avatar'],
                      style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedChild['hoTen'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.cake, size: 16),
                          const SizedBox(width: 4),
                          Text(selectedChild['ngaySinh']),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.school, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(selectedChild['truong'])),
                        ],
                      ),
                      Text('${selectedChild['lop']}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHocTapTab(selectedChild),
                _buildHoTroTab(selectedChild),
                _buildSuKienTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHocTapTab(Map<String, dynamic> child) {
    final phieuDiem = _service.getPhieuDiem(child['treEmId']);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: phieuDiem.length,
      itemBuilder: (context, index) {
        final phieu = phieuDiem[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.description),
            ),
            title: Text(phieu['hocKy'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Điểm TB: ${phieu['diemTB']} - ${phieu['xepLoai']}'),
                Text('Hạnh kiểm: ${phieu['hanhKiem']}'),
                Text('Cập nhật: ${phieu['ngayCapNhat']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to detail
            },
          ),
        );
      },
    );
  }

  Widget _buildHoTroTab(Map<String, dynamic> child) {
    final hoTro = _service.getHoTro(child['treEmId']);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hoTro.length,
      itemBuilder: (context, index) {
        final ht = hoTro[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.card_giftcard, color: Colors.green),
            ),
            title: Text(ht['loaiHoTro'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ht['moTa']),
                const SizedBox(height: 4),
                Text('Ngày cấp: ${ht['ngayCap']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            trailing: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xem minh chứng')),
                );
              },
              child: const Text('Xem MC'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuKienTab() {
    final suKien = _service.getEvents()
        .where((s) => s['trangThai'] == 'Đã kết thúc')
        .toList();

    if (suKien.isEmpty) {
      return const Center(child: Text('Chưa tham gia sự kiện nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suKien.length,
      itemBuilder: (context, index) {
        final sk = suKien[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.event),
            ),
            title: Text(sk['tenSuKien'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(sk['ngayBatDau']),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(sk['diaDiem']),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(sk['trangThai']),
              backgroundColor: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }
}
