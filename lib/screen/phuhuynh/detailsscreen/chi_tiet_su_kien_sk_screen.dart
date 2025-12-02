import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../models/tab_su_kien_ph.dart';
import '../../../providers/phu_huynh.dart';

class ChiTietSuKienScreen extends StatefulWidget {
  final int suKienId;

  const ChiTietSuKienScreen({Key? key, required this.suKienId}) : super(key: key);

  @override
  State<ChiTietSuKienScreen> createState() => _ChiTietSuKienScreenState();
}

class _ChiTietSuKienScreenState extends State<ChiTietSuKienScreen> {
  bool _isExpanded = false;
  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhuHuynhProvider>().loadChiTietSuKien(widget.suKienId);
    });
  }

  Future<void> _handleDangKy(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: const Text('Bạn có chắc chắn muốn đăng ký tham gia sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<PhuHuynhProvider>();
      final response = await provider.dangKySuKien(widget.suKienId);

      if (response != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Reload data
        await provider.loadChiTietSuKien(widget.suKienId);
      }
    }
  }

  Future<void> _handleHuyDangKy(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn chắc chắn muốn hủy đăng ký sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy đăng ký'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<PhuHuynhProvider>();
      final success = await provider.huyDangKySuKien(widget.suKienId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã hủy đăng ký thành công' : 'Hủy đăng ký thất bại'),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (success) {
          await provider.loadChiTietSuKien(widget.suKienId);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          final suKien = provider.chiTietSuKien;
          if (suKien == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Không tìm thấy sự kiện', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          final DateTime? startDate = _parseDate(suKien.ngayBatDau);
          final DateTime? endDate = _parseDate(suKien.ngayKetThuc);
          final bool isEnded = endDate != null && endDate.isBefore(DateTime.now());

          return CustomScrollView(
            slivers: [
              _buildAppBar(suKien),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildInfoSection(suKien, startDate, endDate, isEnded),
                    _buildDescriptionSection(suKien),
                    _buildStatsSection(suKien),
                    _buildLocationSection(suKien),
                    _buildProgramSection(suKien),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          final suKien = provider.chiTietSuKien;
          if (suKien == null) return const SizedBox.shrink();

          final DateTime? endDate = _parseDate(suKien.ngayKetThuc);
          final bool isEnded = endDate != null && endDate.isBefore(DateTime.now());

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: _buildActionButton(suKien, isEnded),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ChiTietSuKienResponse suKien) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF00897B),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          suKien.tenSuKien,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00897B), Color(0xFF00695C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Hiển thị ảnh nếu có, nếu không thì hiển thị pattern + icon
              if (suKien.anhSuKien != null && suKien.anhSuKien!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: '${baseUrl}${suKien.anhSuKien}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: CustomPaint(painter: _PatternPainter()),
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.celebration, size: 80, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                )
              else
              // Hiển thị pattern và icon khi không có ảnh
                ...[
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(painter: _PatternPainter()),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.celebration, size: 80, color: Colors.white70),
                  ),
                ],

              // Gradient overlay để text dễ đọc hơn (chỉ hiện khi có ảnh)
              if (suKien.anhSuKien != null && suKien.anhSuKien!.isNotEmpty)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

              // Badge trạng thái
              if (suKien.daDangKy)
                Positioned(
                  top: 60,
                  right: 16,
                  child: _buildStatusBadge(suKien.trangThaiDangKy),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ChiTietSuKienResponse suKien, DateTime? startDate,
      DateTime? endDate, bool isEnded) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            'Thời gian',
            '${suKien.ngayBatDau} - ${suKien.ngayKetThuc}',
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.person,
            'Người chịu trách nhiệm',
            suKien.nguoiChiuTrachNhiem,
            Colors.purple,
          ),
          if (!isEnded && startDate != null && startDate.isAfter(DateTime.now())) ...[
            const Divider(height: 24),
            _buildCountdownSection(startDate),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ChiTietSuKienResponse suKien) {
    if (suKien.moTa.isEmpty) return const SizedBox.shrink();

    final shouldShowReadMore = suKien.moTa.length > 200;
    final displayText = _isExpanded || !shouldShowReadMore
        ? suKien.moTa
        : '${suKien.moTa.substring(0, 200)}...';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.orange[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayText,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
          ),
          if (shouldShowReadMore)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'Thu gọn' : 'Xem thêm'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ChiTietSuKienResponse suKien) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tình nguyện viên',
              suKien.soLuongTinhNguyenVien.toString(),
              Icons.volunteer_activism,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Trẻ em',
              suKien.soLuongTreEm.toString(),
              Icons.child_care,
              Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ChiTietSuKienResponse suKien) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Địa điểm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suKien.diaDiem,
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text(
                  '${suKien.tenKhuPho} - ${suKien.diaChiKhuPho}',
                  style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSection(ChiTietSuKienResponse suKien) {
    if (suKien.danhSachChuongTrinh.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: Colors.amber[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Chương trình',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suKien.danhSachChuongTrinh.map((chuongTrinh) {
            return _buildProgramItem(chuongTrinh);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProgramItem(ChuongTrinhSuKien chuongTrinh) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Color(0xFF00897B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chuongTrinh.moTa,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDateTime(chuongTrinh.thoiGianBatDau)} - ${_formatDateTime(chuongTrinh.thoiGianKetThuc)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (chuongTrinh.danhSachTietMuc.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...chuongTrinh.danhSachTietMuc.map((tietMuc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tietMuc.tenTietMuc,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${tietMuc.nguoiThucHien}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownSection(DateTime targetDate) {
    final duration = targetDate.difference(DateTime.now());
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text(
                'Sự kiện bắt đầu sau',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                days > 0
                    ? '$days ngày $hours giờ'
                    : '$hours giờ $minutes phút',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String label;

    switch (status.toLowerCase()) {
      case 'chờ duyệt':
        bgColor = Colors.amber;
        label = 'Chờ duyệt';
        break;
      case 'đã duyệt':
        bgColor = Colors.green;
        label = 'Đã duyệt';
        break;
      case 'từ chối':
        bgColor = Colors.red;
        label = 'Từ chối';
        break;
      default:
        bgColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(ChiTietSuKienResponse suKien, bool isEnded) {
    // Sự kiện đã kết thúc
    if (isEnded) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Sự kiện đã kết thúc',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Đã đăng ký
    if (suKien.daDangKy) {
      final trangThai = suKien.trangThaiDangKy.toLowerCase();

      // Chờ duyệt - Cho phép hủy
      if (trangThai == 'chờ duyệt') {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _handleHuyDangKy(context),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Hủy đăng ký', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }

      // Đã duyệt - Không thể hủy
      else if (trangThai == 'đã duyệt') {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.block),
            label: const Text('Không thể hủy', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[700],
              disabledForegroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }

      // Từ chối - Disabled
      else if (trangThai == 'từ chối') {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.close),
            label: const Text('Từ chối', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              disabledBackgroundColor: Colors.red[100],
              foregroundColor: Colors.red[700],
              disabledForegroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }

      // Trạng thái khác (fallback)
      else {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.hourglass_empty),
            label: Text(
              'Đã đăng ký - ${suKien.trangThaiDangKy}',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[100],
              disabledBackgroundColor: Colors.amber[100],
              foregroundColor: Colors.amber[800],
              disabledForegroundColor: Colors.amber[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }
    }

    // Chưa đăng ký
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _handleDangKy(context),
        icon: const Icon(Icons.how_to_reg),
        label: const Text('Đăng ký tham gia', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (e) {
      return dateTimeStr;
    }
  }
}

// Pattern painter for background
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