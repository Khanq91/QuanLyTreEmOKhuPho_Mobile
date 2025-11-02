import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/tab_su_kien_ph.dart';
import '../../providers/phu_huynh.dart';
import 'chi_tiet_su_kien_sk_screen.dart';

class SuKienScreen extends StatefulWidget {
  const SuKienScreen({Key? key}) : super(key: key);

  @override
  State<SuKienScreen> createState() => _SuKienScreenState();
}

class _SuKienScreenState extends State<SuKienScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<Map<String, String>> _filters = [
    {'key': 'sap-dien-ra', 'label': 'Sắp diễn ra', 'icon': 'upcoming'},
    {'key': 'da-dang-ky', 'label': 'Đã đăng ký', 'icon': 'registered'},
    {'key': 'da-ket-thuc', 'label': 'Đã kết thúc', 'icon': 'finished'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = _filters[_tabController.index]['key']!;
      context.read<PhuHuynhProvider>().loadDanhSachSuKien(filter, refresh: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PhuHuynhProvider>().loadMoreSuKien();
    }
  }

  Future<void> _loadData() async {
    final provider = context.read<PhuHuynhProvider>();
    await provider.loadDanhSachSuKien(_filters[0]['key']!, refresh: true);
  }

  Future<void> _onRefresh() async {
    final provider = context.read<PhuHuynhProvider>();
    final currentFilter = _filters[_tabController.index]['key']!;
    await provider.loadDanhSachSuKien(currentFilter, refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sự kiện', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _filters.map((filter) {
            return Tab(
              icon: _getFilterIcon(filter['icon']!),
              text: filter['label'],
            );
          }).toList(),
        ),
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.danhSachSuKien.isEmpty) {
            return _buildShimmerLoading();
          }

          if (provider.errorMessage != null && provider.danhSachSuKien.isEmpty) {
            return _buildErrorState(provider.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildSuKienList(provider, filter['key']!),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _getFilterIcon(String iconKey) {
    switch (iconKey) {
      case 'upcoming':
        return const Icon(Icons.event_available, size: 20);
      case 'registered':
        return const Icon(Icons.how_to_reg, size: 20);
      case 'finished':
        return const Icon(Icons.event_busy, size: 20);
      default:
        return const Icon(Icons.event, size: 20);
    }
  }

  Widget _buildSuKienList(PhuHuynhProvider provider, String filter) {
    final list = provider.danhSachSuKien;

    if (list.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final suKien = list[index];
        return _buildSuKienCard(suKien);
      },
    );
  }

  Widget _buildSuKienCard(DanhSachSuKien suKien) {
    final DateTime? startDate = _parseDate(suKien.ngayBatDau);
    final DateTime? endDate = _parseDate(suKien.ngayKetThuc);
    final bool isUpcoming = startDate != null && startDate.isAfter(DateTime.now());
    final bool isWithin7Days = isUpcoming &&
        startDate.difference(DateTime.now()).inDays <= 7;
    final bool isEnded = endDate != null && endDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChiTietSuKienScreen(suKienId: suKien.suKienId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với gradient và status badge
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(suKien),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: _PatternPainter(),
                      ),
                    ),
                  ),
                  // Status Badge (nếu đã đăng ký)
                  if (suKien.daDangKy)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildStatusBadge(suKien.trangThaiDangKy),
                    ),
                  // Icon và Tên sự kiện
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.celebration,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suKien.tenSuKien,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung chi tiết
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian
                  _buildInfoRow(
                    Icons.access_time,
                    '${suKien.ngayBatDau} - ${suKien.ngayKetThuc}',
                    const Color(0xFF00897B),
                  ),
                  const SizedBox(height: 10),

                  // Địa điểm
                  _buildInfoRow(
                    Icons.location_on,
                    suKien.diaDiem ?? 'Chưa có thông tin',
                    Colors.red[400]!,
                  ),
                  const SizedBox(height: 10),

                  // Khu phố
                  _buildInfoRow(
                    Icons.home_work,
                    suKien.tenKhuPho ?? 'Chưa có thông tin',
                    Colors.blue[400]!,
                  ),

                  // Countdown nếu sắp diễn ra
                  if (isWithin7Days && startDate != null) ...[
                    const SizedBox(height: 12),
                    _buildCountdown(startDate),
                  ],

                  // Badge "Đã kết thúc"
                  if (isEnded) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(
                            'Đã kết thúc',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  List<Color> _getGradientColors(DanhSachSuKien suKien) {
    if (suKien.daDangKy) {
      return [const Color(0xFF00897B), const Color(0xFF00695C)];
    }
    return [const Color(0xFF1E88E5), const Color(0xFF1565C0)];
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'chờ duyệt':
        bgColor = Colors.amber;
        textColor = Colors.white;
        label = 'Chờ duyệt';
        break;
      case 'đã duyệt':
        bgColor = Colors.green;
        textColor = Colors.white;
        label = 'Đã duyệt';
        break;
      case 'từ chối':
        bgColor = Colors.red;
        textColor = Colors.white;
        label = 'Từ chối';
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown(DateTime targetDate) {
    final duration = targetDate.difference(DateTime.now());
    final days = duration.inDays;
    final hours = duration.inHours % 24;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            days > 0
                ? 'Còn $days ngày $hours giờ'
                : 'Còn $hours giờ ${duration.inMinutes % 60} phút',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    IconData icon;

    switch (filter) {
      case 'sap-dien-ra':
        message = 'Chưa có sự kiện sắp diễn ra';
        icon = Icons.event_available;
        break;
      case 'da-dang-ky':
        message = 'Bạn chưa đăng ký sự kiện nào';
        icon = Icons.how_to_reg;
        break;
      case 'da-ket-thuc':
        message = 'Chưa có sự kiện đã kết thúc';
        icon = Icons.event_busy;
        break;
      default:
        message = 'Không có sự kiện';
        icon = Icons.event;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(size.width * (i * 0.15), size.height * 0.3),
        20 + (i * 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}