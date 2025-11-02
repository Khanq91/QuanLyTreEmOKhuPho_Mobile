import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tab_thong_bao_ph.dart';
import '../../providers/phu_huynh.dart';
import 'chi_tiet_su_kien_screen.dart';
import 'chi_tiet_su_kien_sk_screen.dart';

class TabThongBaoScreen extends StatefulWidget {
  const TabThongBaoScreen({Key? key}) : super(key: key);

  @override
  State<TabThongBaoScreen> createState() => _TabThongBaoScreenState();
}

class _TabThongBaoScreenState extends State<TabThongBaoScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'all'; // 'all' hoặc 'unread'
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<PhuHuynhProvider>();
    await provider.loadDanhSachThongBao(filter: _selectedFilter);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    // TODO: Implement pagination API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter Tabs
              _buildFilterTabs(provider),
              // Danh sách thông báo
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: _buildThongBaoList(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(PhuHuynhProvider provider) {
    final soLuongChuaDoc = provider.thongBaoData?.soLuongChuaDoc ?? 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(
              label: 'Tất cả',
              value: 'all',
              isSelected: _selectedFilter == 'all',
              badge: null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterChip(
              label: 'Chưa đọc',
              value: 'unread',
              isSelected: _selectedFilter == 'unread',
              badge: soLuongChuaDoc > 0 ? soLuongChuaDoc : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
    int? badge,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.red : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
            _currentPage = 1;
          });
          _loadInitialData();
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildThongBaoList(PhuHuynhProvider provider) {
    if (provider.isLoading && provider.thongBaoData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final thongBaoList = provider.thongBaoData?.danhSachThongBao ?? [];

    if (thongBaoList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: thongBaoList.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == thongBaoList.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildThongBaoCard(thongBaoList[index], provider);
      },
    );
  }

  Widget _buildThongBaoCard(ThongBaoInfo thongBao, PhuHuynhProvider provider) {
    return Dismissible(
      key: Key('thongbao_${thongBao.thongBaoID}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.done, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        if (!thongBao.daDoc) {
          await provider.danhDauDaDoc(thongBao.thongBaoID);
          return false; // Không xóa card, chỉ đánh dấu
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: thongBao.daDoc ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: thongBao.daDoc
              ? BorderSide.none
              : BorderSide(color: Colors.blue.shade200, width: 2),
        ),
        child: InkWell(
          onTap: () async {
            // Đánh dấu đã đọc
            if (!thongBao.daDoc) {
              await provider.danhDauDaDoc(thongBao.thongBaoID);
            }

            // Mở chi tiết sự kiện nếu có
            if (thongBao.suKienID != null) {
              // TODO: Navigate to SuKienChiTietScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => SuKienChiTietScreen(
                  //   suKienID: thongBao.suKienID!,
                  //   tenSuKien: thongBao.tenSuKien ?? 'Chi tiết sự kiện',
                  // ),
                  builder: (context) => ChiTietSuKienScreen(suKienId: thongBao.suKienID!),
                ),
              );
            } else {
              _showThongBaoDialog(thongBao);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicator chấm xanh
                if (!thongBao.daDoc)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4, right: 12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 22),
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: thongBao.suKienID != null
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    thongBao.suKienID != null
                        ? Icons.event
                        : Icons.notifications,
                    color: thongBao.suKienID != null
                        ? Colors.blue.shade700
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Nội dung
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (thongBao.tenSuKien != null)
                        Text(
                          thongBao.tenSuKien!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: thongBao.daDoc
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        thongBao.noiDung,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                          thongBao.daDoc ? FontWeight.normal : FontWeight.w600,
                          color: thongBao.daDoc
                              ? Colors.grey.shade700
                              : Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            thongBao.ngayThongBao,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThongBaoDialog(ThongBaoInfo thongBao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thongBao.noiDung),
            const SizedBox(height: 12),
            Text(
              thongBao.ngayThongBao,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (thongBao.suKienID == null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sự kiện không tồn tại',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter == 'unread'
                ? Icons.mark_email_read
                : Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'unread'
                ? 'Không có thông báo chưa đọc'
                : 'Chưa có thông báo nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}