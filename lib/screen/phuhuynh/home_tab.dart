import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../providers/phu_huynh.dart';
import 'main_screen.dart';

class ParentHomeTab extends StatefulWidget {
  const ParentHomeTab({Key? key}) : super(key: key);

  @override
  State<ParentHomeTab> createState() => _ParentHomeTabState();
}

class _ParentHomeTabState extends State<ParentHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<PhuHuynhProvider>();
    await Future.wait([
      provider.loadDashboard(),
      // provider.loadThongBao(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final phuHuynhProvider = context.watch<PhuHuynhProvider>();
    final unreadCount = phuHuynhProvider.dashboard?.soThongBaoChuaDoc ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  final parentState = context.findAncestorStateOfType<ParentMainScreenState>();
                  parentState?.navigateToTab(3);
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
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: phuHuynhProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : phuHuynhProvider.errorMessage != null
          ? _buildErrorWidget(phuHuynhProvider)
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(authProvider, phuHuynhProvider),
              const SizedBox(height: 24),
              if (phuHuynhProvider.dashboard?.thongTinHocTap != null)
                _buildHocTapCard(phuHuynhProvider),
              const SizedBox(height: 16),
              _buildHoTroCard(phuHuynhProvider),
              const SizedBox(height: 16),
              if (phuHuynhProvider.dashboard?.suKienSapToi.isNotEmpty ?? false)
                _buildSuKienCard(phuHuynhProvider),
              const SizedBox(height: 16),
              if (phuHuynhProvider.dashboard?.thongBaoChuaDoc.isNotEmpty ?? false)
                _buildThongBaoChuaDocCard(phuHuynhProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(PhuHuynhProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
      AuthProvider authProvider, PhuHuynhProvider phuHuynhProvider) {
    final danhSachCon = phuHuynhProvider.dashboard?.danhSachCon ?? [];
    final firstChild = danhSachCon.isNotEmpty ? danhSachCon.first : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              backgroundImage: firstChild?.anh != null
                  ? NetworkImage("http://10.0.2.2:5035${firstChild!.anh!}")
                  : null,
              child: firstChild?.anh == null
                  ? const Icon(Icons.child_care, size: 32, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${authProvider.hoTen}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (firstChild != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      firstChild.hoTen,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${firstChild.tuoi} tuổi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                  if (danhSachCon.length > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      'và ${danhSachCon.length - 1} con khác',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHocTapCard(PhuHuynhProvider provider) {
    final thongTin = provider.dashboard!.thongTinHocTap!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin học tập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Text(
              thongTin.tenTreEm,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${thongTin.tenLop} - ${thongTin.tenTruong}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Điểm TB: ${thongTin.diemTrungBinh.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 14),
                ),
                Chip(
                  label: Text(thongTin.xepLoai),
                  backgroundColor: _getXepLoaiColor(thongTin.xepLoai),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hạnh kiểm: ${thongTin.hanhKiem}',
              style: const TextStyle(fontSize: 14),
            ),
            if (thongTin.ghiChu != null && thongTin.ghiChu!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        thongTin.ghiChu!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Cập nhật: ${DateFormat('dd/MM/yyyy').format(thongTin.ngayCapNhat)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _getXepLoaiColor(String xepLoai) {
    switch (xepLoai.toLowerCase()) {
      case 'xuất sắc':
        return const Color(0xFFFFD700);
      case 'giỏi':
        return Colors.green;
      case 'khá':
        return Colors.blue;
      case 'trung bình':
        return Colors.orange;
      case 'yếu':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildHoTroCard(PhuHuynhProvider provider) {
    final hoTroDaNhan = provider.dashboard?.hoTroDaNhan ?? [];

    // Tính tổng hỗ trợ trong tháng này
    final now = DateTime.now();
    final hoTroThangNay = hoTroDaNhan.where((ht) {
      return ht.ngayCap.month == now.month && ht.ngayCap.year == now.year;
    }).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Hỗ trợ đã nhận',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tháng này',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$hoTroThangNay lần',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${hoTroDaNhan.length} lần',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (hoTroDaNhan.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Hỗ trợ gần đây:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...hoTroDaNhan.take(2).map((ht) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ht.loaiHoTro,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ht.ngayCapFormatted,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuKienCard(PhuHuynhProvider provider) {
    final suKien = provider.dashboard!.suKienSapToi.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Sự kiện sắp tới',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ...suKien.map((sk) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Navigate to event detail
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sk.tenSuKien,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (sk.isDienRaHomNay)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Hôm nay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            sk.ngayBatDauFormatted,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (sk.soNgayConLai >= 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${sk.soNgayConLai} ngày nữa)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sk.diaDiem,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (sk.moTa != null && sk.moTa!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          sk.moTa!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildThongBaoChuaDocCard(PhuHuynhProvider provider) {
    final thongBao = provider.dashboard!.thongBaoChuaDoc.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông báo chưa đọc',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    final parentState = context.findAncestorStateOfType<ParentMainScreenState>();
                    parentState?.navigateToTab(3);
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const Divider(),
            ...thongBao.map((tb) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Navigate to notification detail
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tb.tenSuKien != null) ...[
                        Text(
                          tb.tenSuKien!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        tb.noiDung,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tb.thoiGianTuongDoi,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}