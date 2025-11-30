// screens/tinh_nguyen_vien/event_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/tab_su_kien_tnv.dart';
import '../../../providers/tinh_nguyen_vien.dart';

class EventDetailScreen extends StatefulWidget {
  final int suKienId;

  const EventDetailScreen({Key? key, required this.suKienId}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isExpanded = false;
  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VolunteerProvider>().loadChiTietSuKien(widget.suKienId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingSuKien) {
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

          if (provider.errorMessageSuKien != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text('Đã có lỗi xảy ra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessageSuKien!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadChiTietSuKien(widget.suKienId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          final event = provider.suKienChiTiet;
          if (event == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 80, color: Colors.grey),
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

          final DateTime? startDate = event.ngayBatDau;
          final DateTime? endDate = event.ngayKetThuc;
          final bool isEnded = endDate != null && endDate.isBefore(DateTime.now());

          return CustomScrollView(
            slivers: [
              _buildAppBar(event),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildInfoSection(event, startDate, endDate, isEnded),
                    if (event.moTa != null && event.moTa!.isNotEmpty)
                      _buildDescriptionSection(event.moTa!),
                    _buildStatsSection(event),
                    _buildLocationSection(event),
                    if (event.thoiGianChiTiet.isNotEmpty)
                      _buildScheduleSection(event.thoiGianChiTiet),
                    if (event.daPhanCong)
                      _buildAssignmentSection(event),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          final event = provider.suKienChiTiet;
          if (event == null) return const SizedBox.shrink();

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
              child: _buildActionButton(event),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildAppBar(SuKienChiTietDto event) {
  //   return SliverAppBar(
  //     expandedHeight: 200,
  //     pinned: true,
  //     backgroundColor: const Color(0xFF00897B),
  //     foregroundColor: Colors.white,
  //     flexibleSpace: FlexibleSpaceBar(
  //       title: Text(
  //         event.tenSuKien,
  //         style: const TextStyle(
  //           fontWeight: FontWeight.bold,
  //           fontSize: 16,
  //         ),
  //       ),
  //       background: Container(
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //         ),
  //         child: Stack(
  //           children: [
  //
  //             if (event.anhSuKien != null && event.anhSuKien!.isNotEmpty)
  //               Positioned.fill(
  //                 child: CachedNetworkImage(
  //                   imageUrl: '${baseUrl}${event.anhSuKien}',
  //                   fit: BoxFit.cover,
  //                   placeholder: (context, url) => Container(
  //                     color: Colors.grey[300],
  //                     child: const Center(child: CircularProgressIndicator()),
  //                   ),
  //                   errorWidget: (context, url, error) => const Icon(
  //                       Icons.volunteer_activism,
  //                       size: 80,
  //                       color: Colors.white70
  //                   ),
  //                 ),
  //               )
  //             else
  //               Positioned.fill(
  //                 child: Opacity(
  //                   opacity: 0.1,
  //                   child: CustomPaint(painter: _PatternPainter()),
  //                 ),
  //               ),
  //             Positioned.fill(
  //               child: Opacity(
  //                 opacity: 0.1,
  //                 child: CustomPaint(painter: _PatternPainter()),
  //               ),
  //             ),
  //             const Center(
  //               child: Icon(Icons.volunteer_activism, size: 80, color: Colors.white70),
  //             ),
  //             if (event.daDangKy)
  //               Positioned(
  //                 top: 60,
  //                 right: 16,
  //                 child: _buildStatusBadge(event.trangThaiDangKy ?? ''),
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildAppBar(SuKienChiTietDto event) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF00897B),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          event.tenSuKien,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color:  Colors.white,
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
              if (event.anhSuKien != null && event.anhSuKien!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: '${baseUrl}${event.anhSuKien}',
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
                          child: Icon(Icons.volunteer_activism, size: 80, color: Colors.white70),
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
                    child: Icon(Icons.volunteer_activism, size: 80, color: Colors.white70),
                  ),
                ],

              // Gradient overlay để text dễ đọc hơn (chỉ hiện khi có ảnh)
              if (event.anhSuKien != null && event.anhSuKien!.isNotEmpty)
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
              if (event.daDangKy)
                Positioned(
                  top: 60,
                  right: 16,
                  child: _buildStatusBadge(event.trangThaiDangKy ?? ''),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(SuKienChiTietDto event, DateTime? startDate,
      DateTime? endDate, bool isEnded) {
    final dateFormat = DateFormat('dd/MM/yyyy');

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
            '${dateFormat.format(event.ngayBatDau)} - ${dateFormat.format(event.ngayKetThuc)}',
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.person,
            'Người chịu trách nhiệm',
            event.nguoiChiuTrachNhiem,
            Colors.purple,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_city,
            'Khu phố',
            '${event.tenKhuPho} - ${event.diaChiKhuPho}',
            Colors.indigo,
          ),
          if (event.ngayDangKy != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.app_registration,
              'Ngày đăng ký',
              dateFormat.format(event.ngayDangKy!),
              Colors.teal,
            ),
          ],
          if (!isEnded && startDate != null && startDate.isAfter(DateTime.now())) ...[
            const Divider(height: 24),
            _buildCountdownSection(startDate),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    final shouldShowReadMore = description.length > 200;
    final displayText = _isExpanded || !shouldShowReadMore
        ? description
        : '${description.substring(0, 200)}...';

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

  Widget _buildStatsSection(SuKienChiTietDto event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tình nguyện viên',
              '${event.soLuongDaDangKy}/${event.soLuongTinhNguyenVien}',
              Icons.volunteer_activism,
              Colors.green,
              event.daDay,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Trẻ em',
              event.soLuongTreEm.toString(),
              Icons.child_care,
              Colors.pink,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isFull) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isFull ? Border.all(color: Colors.orange, width: 2) : null,
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
          if (isFull)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Đã đủ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(SuKienChiTietDto event) {
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
            event.diaDiem,
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          ),
          if (event.daHetHan)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Đã hết hạn đăng ký',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(List<ThoiGianChiTietDto> schedule) {
    final timeFormat = DateFormat('HH:mm dd/MM/yyyy');

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
                'Lịch trình chi tiết',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...schedule.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
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
                      if (item.moTa != null && item.moTa!.isNotEmpty)
                        Text(
                          item.moTa!,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${timeFormat.format(item.thoiGianBatDau)} - ${timeFormat.format(item.thoiGianKetThuc)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAssignmentSection(SuKienChiTietDto event) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.work, color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Công việc được phân công',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.congViecPhanCong ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (event.ghiChuPhanCong != null && event.ghiChuPhanCong!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ghi chú: ${event.ghiChuPhanCong}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.ngayPhanCong != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Ngày phân công: ${dateFormat.format(event.ngayPhanCong!)}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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

    switch (status) {
      case 'Đã duyệt':
        bgColor = Colors.green;
        label = 'Đã duyệt';
        break;
      case 'Chờ duyệt':
        bgColor = Colors.amber;
        label = 'Chờ duyệt';
        break;
      case 'Từ chối':
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

  Widget _buildActionButton(SuKienChiTietDto event) {
    if (event.coTheDangKy) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => _showDangKyDialog(),
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
    } else if (event.daDangKy && event.choPheDuyet) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => _showHuyDangKyDialog(event),
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
    } else if (event.daDuyet) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Đã được duyệt',
                style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    } else if (event.biTuChoi) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'Đã bị từ chối',
                style: TextStyle(fontSize: 16, color: Colors.red[700], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    } else if (event.daHetHan || event.daDay) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            event.daHetHan ? 'Đã hết hạn đăng ký' : 'Đã đủ tình nguyện viên',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showDangKyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng ký'),
        content: const Text('Bạn có chắc muốn đăng ký tham gia sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<VolunteerProvider>().dangKySuKien(widget.suKienId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Đăng ký thành công!' : 'Đăng ký thất bại!'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }

  void _showHuyDangKyDialog(SuKienChiTietDto event) {
    final lyDoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy đăng ký'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng cho biết lý do hủy đăng ký:'),
            const SizedBox(height: 12),
            TextField(
              controller: lyDoController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thoát'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (lyDoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập lý do'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              final success = await context.read<VolunteerProvider>().huyDangKySuKien(
                event.dangKyId!,
                lyDoController.text.trim(),
                widget.suKienId,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Hủy đăng ký thành công!' : 'Hủy đăng ký thất bại!'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy đăng ký'),
          ),
        ],
      ),
    );
  }
}

// Pattern painter for background decoration
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