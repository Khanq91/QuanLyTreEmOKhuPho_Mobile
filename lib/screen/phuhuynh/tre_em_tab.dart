import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screen/phuhuynh/thong_tin_tre_em_screen.dart';
import 'package:mobile/screen/phuhuynh/xem_anh_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/tab_con_toi.dart';
import '../../providers/phu_huynh.dart';
import 'chi_tiet_phieu_hoc_tap_screen.dart';

class ParentChildrenScreen extends StatefulWidget {
  const ParentChildrenScreen({Key? key}) : super(key: key);

  @override
  State<ParentChildrenScreen> createState() => _ParentChildrenScreenState();
}

class _ParentChildrenScreenState extends State<ParentChildrenScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentChildIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<PhuHuynhProvider>();
    await provider.loadDanhSachCon();
    if (provider.danhSachCon.isNotEmpty) {
      _loadChildData(provider.danhSachCon[0].treEmID);
    }
  }

  Future<void> _loadChildData(int treEmId) async {
    final provider = context.read<PhuHuynhProvider>();
    await Future.wait([
      provider.loadPhieuHocTap(treEmId),
      provider.loadHoTroPhucLoi(treEmId),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Con tôi'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.danhSachCon.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.danhSachCon.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _loadInitialData();
              if (provider.danhSachCon.isNotEmpty) {
                await _loadChildData(
                    provider.danhSachCon[_currentChildIndex].treEmID);
              }
            },
            child: Column(
              children: [
                // Carousel Section
                _buildCarouselSection(provider),
                const SizedBox(height: 8),
                // Tab Bar
                _buildTabBar(),
                // Tab View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHocTapTab(provider),
                      _buildHoTroTab(provider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarouselSection(PhuHuynhProvider provider) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Carousel
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentChildIndex = index;
                });
                _loadChildData(provider.danhSachCon[index].treEmID);
              },
              itemCount: provider.danhSachCon.length,
              itemBuilder: (context, index) {
                return _buildChildCard(provider.danhSachCon[index]);
              },
            ),
          ),
          const SizedBox(height: 12),
          // Page Indicator
          if (provider.danhSachCon.length > 1)
            SmoothPageIndicator(
              controller: _pageController,
              count: provider.danhSachCon.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Colors.grey.shade300,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildCard(TreEmBasicInfo child) {
    final isMale = child.gioiTinh.toLowerCase() == 'nam';
    final avatarColor = isMale ? Colors.blue.shade100 : Colors.pink.shade100;
    final iconColor = isMale ? Colors.blue.shade700 : Colors.pink.shade700;
    final baseUrl = 'http://10.0.2.2:5035';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar với ảnh thật hoặc icon
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor, width: 2),
                ),
                child: ClipOval(
                  child: child.anh != null && child.anh!.isNotEmpty
                      ? Image.network(
                    '$baseUrl${child.anh}',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
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
                      // Nếu load ảnh lỗi, hiển thị icon
                      return Icon(
                        isMale ? Icons.boy : Icons.girl,
                        size: 48,
                        color: iconColor,
                      );
                    },
                  )
                      : Icon(
                    isMale ? Icons.boy : Icons.girl,
                    size: 48,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    child.hoTen,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.cake, _formatDate(child.ngaySinh)),
                  const SizedBox(height: 2),
                  _buildInfoRow(Icons.school, child.tenTruong),
                  const SizedBox(height: 2),
                  _buildInfoRow(Icons.class_, child.capHoc),
                ],
              ),
            ),
            // Nút xem chi tiết
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChiTietTreEmScreen(child: child),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_ios),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Học tập', icon: Icon(Icons.school, size: 20)),
          Tab(text: 'Hỗ trợ', icon: Icon(Icons.volunteer_activism, size: 20)),
        ],
      ),
    );
  }

  Widget _buildHocTapTab(PhuHuynhProvider provider) {
    if (provider.danhSachCon.isEmpty) return const SizedBox();

    final treEmId = provider.danhSachCon[_currentChildIndex].treEmID;
    final phieuList = provider.getPhieuHocTap(treEmId);

    if (provider.isLoading) {
      return _buildShimmerList();
    }

    if (phieuList.isEmpty) {
      return _buildEmptyMessage('Chưa có phiếu học tập nào');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: phieuList.length,
      itemBuilder: (context, index) {
        return _buildPhieuHocTapCard(phieuList[index]);
      },
    );
  }

  Widget _buildPhieuHocTapCard(PhieuHocTapInfo phieu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChiTietPhieuHocTapScreen(phieu: phieu),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    phieu.tenLop,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildXepLoaiChip(phieu.xepLoai),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      'Điểm TB',
                      phieu.diemTrungBinh.toStringAsFixed(1),
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: _buildScoreItem(
                      'Hạnh kiểm',
                      phieu.hanhKiem,
                      Icons.favorite,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Cập nhật: ${_formatDate(phieu.ngayCapNhat)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            Text(value,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildXepLoaiChip(String xepLoai) {
    Color color;
    IconData icon;

    switch (xepLoai.toLowerCase()) {
      case 'xuất sắc':
        color = Colors.purple;
        icon = Icons.emoji_events;
        break;
      case 'giỏi':
        color = Colors.green;
        icon = Icons.stars;
        break;
      case 'khá':
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'trung bình':
        color = Colors.orange;
        icon = Icons.radio_button_checked;
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(xepLoai, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildHoTroTab(PhuHuynhProvider provider) {
    if (provider.danhSachCon.isEmpty) return const SizedBox();

    final treEmId = provider.danhSachCon[_currentChildIndex].treEmID;
    final hoTroData = provider.getHoTro(treEmId);

    if (provider.isLoading) {
      return _buildShimmerList();
    }

    if (hoTroData == null ||
        (hoTroData.danhSachHoTro.isEmpty && hoTroData.danhSachUngHo.isEmpty)) {
      return _buildEmptyMessage('Chưa có thông tin hỗ trợ');
    }

    return _HoTroTabContent(
      hoTroData: hoTroData,
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông tin con',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
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

// ============================================================================
// HỖ TRỢ TAB CONTENT (với Filter)
// ============================================================================
class _HoTroTabContent extends StatefulWidget {
  final TabHoTroResponse hoTroData;

  const _HoTroTabContent({required this.hoTroData});

  @override
  State<_HoTroTabContent> createState() => _HoTroTabContentState();
}

class _HoTroTabContentState extends State<_HoTroTabContent> {
  int _selectedFilter = 0; // 0: Tất cả, 1: Phúc lợi, 2: Ủng hộ

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Tất cả'), icon: Icon(Icons.all_inclusive)),
              ButtonSegment(value: 1, label: Text('Phúc lợi'), icon: Icon(Icons.handshake)),
              ButtonSegment(value: 2, label: Text('Ủng hộ'), icon: Icon(Icons.favorite)),
            ],
            selected: {_selectedFilter},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _selectedFilter = newSelection.first;
              });
            },
          ),
        ),
        // List
        Expanded(
          child: _buildFilteredList(),
        ),
      ],
    );
  }

  Widget _buildFilteredList() {
    final hoTroList = widget.hoTroData.danhSachHoTro;
    final ungHoList = widget.hoTroData.danhSachUngHo;

    List<Widget> items = [];

    if (_selectedFilter == 0 || _selectedFilter == 1) {
      items.addAll(hoTroList.map((item) => _buildHoTroCard(item)));
    }

    if (_selectedFilter == 0 || _selectedFilter == 2) {
      items.addAll(ungHoList.map((item) => _buildUngHoCard(item)));
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Widget _buildHoTroCard(HoTroPhucLoiInfo hoTro) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.handshake, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hoTro.loaiHoTro,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Người chịu trách nhiệm: ${hoTro.nguoiChiuTrachNhiem}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hoTro.moTa,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(hoTro.ngayCap),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                if (hoTro.danhSachMinhChung.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      _showMinhChungDialog(hoTro.danhSachMinhChung);
                    },
                    icon: const Icon(Icons.image, size: 16),
                    label: Text('Xem minh chứng (${hoTro.danhSachMinhChung.length})'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUngHoCard(UngHoInfo ungHo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.favorite, color: Colors.pink.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ungHo.loaiUngHo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${ungHo.tenManhThuongQuan} (${ungHo.loaiManhThuongQuan})',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text(
                    _formatCurrency(ungHo.soTien),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
            if (ungHo.ghiChu.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                ungHo.ghiChu,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(ungHo.ngayUngHo),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMinhChungDialog(List<MinhChungInfo> minhChungList) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Minh chứng'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: minhChungList.length,
                  itemBuilder: (context, index) {
                    final mc = minhChungList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.image, color: Colors.blue),
                        title: Text(mc.loaiMinhChung),
                        subtitle: Text(_formatDate(mc.ngayCap)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewerScreen(
                                imageUrl: "http://10.0.2.2:5035${mc.filePath}",
                                title: mc.loaiMinhChung,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(amount)} Đồng';
  }
}