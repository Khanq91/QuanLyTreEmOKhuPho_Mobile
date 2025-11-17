import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../models/tab_con_toi.dart';
import '../../../providers/phu_huynh.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../detailsscreen/chi_tiet_phieu_hoc_tap_screen.dart';
import '../detailsscreen/chi_tiet_su_kien_sk_screen.dart';
import '../detailsscreen/thong_tin_tre_em_screen.dart';
import '../../other/xem_anh_screen.dart';

class ParentChildrenScreen extends StatefulWidget {
  const ParentChildrenScreen({Key? key}) : super(key: key);

  @override
  State<ParentChildrenScreen> createState() => _ParentChildrenScreenState();
}

class _ParentChildrenScreenState extends State<ParentChildrenScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentChildIndex = 0;
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isFirstLoad) {
      _reloadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<PhuHuynhProvider>();
    await provider.loadDanhSachCon();
    if (provider.danhSachCon.isNotEmpty) {
      await _loadChildData(provider.danhSachCon[0].treEmID);
    }
    _isFirstLoad = false;
  }

  Future<void> _reloadData() async {
    final provider = context.read<PhuHuynhProvider>();
    await provider.loadDanhSachCon();
    if (provider.danhSachCon.isNotEmpty && mounted) {
      final currentIndex = _currentChildIndex < provider.danhSachCon.length
          ? _currentChildIndex
          : 0;
      await _loadChildData(provider.danhSachCon[currentIndex].treEmID);
    }
  }

  Future<void> _loadChildData(int treEmId) async {
    final provider = context.read<PhuHuynhProvider>();
    await Future.wait([
      provider.loadPhieuHocTap(treEmId),
      provider.loadQuaDaNhan(treEmId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Con tôi', style: AppTextStyles.appBarTitle),
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.danhSachCon.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.danhSachCon.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reloadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: _buildEmptyState(),
                ),
              ),
            );
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
                _buildCarouselSection(provider),
                SizedBox(height: AppDimensions.spacingXS),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHocTapTab(provider),
                      _buildQuaDaNhanTab(provider),
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

  // ==========================================================================
  // CAROUSEL SECTION
  // ==========================================================================
  Widget _buildCarouselSection(PhuHuynhProvider provider) {
    return Container(
      color: AppColors.primaryOverlay,
      padding: AppDimensions.paddingSymmetric(
        vertical: AppDimensions.spacingMD,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
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
          SizedBox(height: AppDimensions.spacingSM),
          if (provider.danhSachCon.length > 1)
            SmoothPageIndicator(
              controller: _pageController,
              count: provider.danhSachCon.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.divider,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildCard(TreEmBasicInfo child) {
    final isMale = child.gioiTinh.toLowerCase() == 'nam';
    final avatarColor = isMale
        ? AppColors.info.withOpacity(0.15)
        : Colors.pink.shade100;
    final iconColor = isMale
        ? AppColors.info
        : Colors.pink.shade700;
    final baseUrl = 'http://10.0.2.2:5035';

    return Card(
      margin: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      elevation: AppDimensions.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
        child: Row(
          children: [
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
                width: AppDimensions.avatarXL,
                height: AppDimensions.avatarXL,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: AppDimensions.borderThick,
                  ),
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
                      return Icon(
                        isMale ? Icons.boy : Icons.girl,
                        size: AppDimensions.iconLG,
                        color: iconColor,
                      );
                    },
                  )
                      : Icon(
                    isMale ? Icons.boy : Icons.girl,
                    size: AppDimensions.iconLG,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    child.hoTen,
                    style: AppTextStyles.headingMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.spacingXXS),
                  _buildInfoRow(Icons.cake, _formatDate(child.ngaySinh)),
                  SizedBox(height: 2),
                  _buildInfoRow(Icons.school, child.tenTruong),
                  SizedBox(height: 2),
                  _buildInfoRow(Icons.class_, child.capHoc),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChiTietTreEmScreen(child: child),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                size: AppDimensions.iconXS,
              ),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXS,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: AppDimensions.spacingXXS),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TAB BAR
  // ==========================================================================
  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.labelLarge,
        tabs: [
          Tab(
            text: 'Học tập',
            icon: Icon(Icons.school, size: AppDimensions.iconSM),
          ),
          Tab(
            text: 'Quà đã nhận',
            icon: Icon(Icons.card_giftcard, size: AppDimensions.iconSM),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HỌC TẬP TAB
  // ==========================================================================
  Widget _buildHocTapTab(PhuHuynhProvider provider) {
    if (provider.danhSachCon.isEmpty) return const SizedBox();

    final treEmId = provider.danhSachCon[_currentChildIndex].treEmID;
    final phieuList = provider.getPhieuHocTap(treEmId);

    if (provider.isLoading) {
      return _buildShimmerList();
    }

    if (phieuList.isEmpty) {
      return _buildEmptyMessage(
        'Chưa có phiếu học tập nào',
        Icons.school,
      );
    }

    return ListView.builder(
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: phieuList.length,
      itemBuilder: (context, index) {
        return _buildPhieuHocTapCard(phieuList[index]);
      },
    );
  }

  Widget _buildPhieuHocTapCard(PhieuHocTapInfo phieu) {
    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderExtraThick,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChiTietPhieuHocTapScreen(phieu: phieu),
              ),
            );
          },
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
            ),
            padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        phieu.tenLop,
                        style: AppTextStyles.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingXS),
                    _buildXepLoaiChip(phieu.xepLoai),
                  ],
                ),
                Divider(
                  height: AppDimensions.spacingLG,
                  color: AppColors.divider,
                  thickness: AppDimensions.dividerThickness,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreItem(
                        'Điểm TB',
                        phieu.diemTrungBinh.toStringAsFixed(1),
                        Icons.star,
                        AppColors.accent,
                      ),
                    ),
                    Expanded(
                      child: _buildScoreItem(
                        'Hạnh kiểm',
                        phieu.hanhKiem,
                        Icons.favorite,
                        AppColors.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingSM),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: AppDimensions.iconXS - 2,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppDimensions.spacingXXS),
                    Text(
                      'Năm học: ${_formatDate(phieu.ngayCapNhat)}',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: AppDimensions.iconXS - 2,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSM - 2, color: color),
          SizedBox(width: AppDimensions.spacingXS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.labelSmall),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXepLoaiChip(String xepLoai) {
    final color = AppColors.getXepLoaiColor(xepLoai);
    IconData icon;

    switch (xepLoai.toLowerCase()) {
      case 'xuất sắc':
        icon = Icons.emoji_events;
        break;
      case 'giỏi':
        icon = Icons.stars;
        break;
      case 'khá':
        icon = Icons.check_circle;
        break;
      case 'trung bình':
        icon = Icons.radio_button_checked;
        break;
      default:
        icon = Icons.circle;
    }

    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.chipPaddingH,
        vertical: AppDimensions.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: AppDimensions.spacingXXS),
          Text(
            xepLoai,
            style: AppTextStyles.chip,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // QUÀ ĐÃ NHẬN TAB
  // ==========================================================================
  Widget _buildQuaDaNhanTab(PhuHuynhProvider provider) {
    if (provider.danhSachCon.isEmpty) return const SizedBox();

    final treEmId = provider.danhSachCon[_currentChildIndex].treEmID;
    final quaData = provider.getQuaDaNhan(treEmId);

    if (provider.isLoading) {
      return _buildShimmerList();
    }

    // if (quaData == null || quaData.danhSachQua.isEmpty) {
    //   return _buildEmptyMessage(
    //     'Chưa có quà nào',
    //     Icons.card_giftcard,
    //   );
    // }

    return _QuaDaNhanTabContent(
      quaData: quaData!,
      treEmId: treEmId,
    );
  }

  // ==========================================================================
  // SHIMMER LOADING
  // ==========================================================================
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.surfaceVariant,
          highlightColor: AppColors.surface,
          child: Container(
            margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(
                AppDimensions.cardRadius,
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // EMPTY STATES
  // ==========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: AppDimensions.iconXXL,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(
            'Chưa có thông tin con',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXXL,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppDimensions.spacingSM),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
// QUÀ ĐÃ NHẬN TAB CONTENT (với Filter)
// ============================================================================
class _QuaDaNhanTabContent extends StatefulWidget {
  final TabQuaDaNhanResponse quaData;
  final int treEmId;

  const _QuaDaNhanTabContent({
    required this.quaData,
    required this.treEmId,
  });

  @override
  State<_QuaDaNhanTabContent> createState() => _QuaDaNhanTabContentState();
}

class _QuaDaNhanTabContentState extends State<_QuaDaNhanTabContent> {
  String _selectedFilter = 'all'; // 'all', 'da-nhan', 'dang-tien-hanh'

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
          color: AppColors.surface,
          child: _buildFilterChips(),
        ),
        // List
        Expanded(
          child: _buildFilteredList(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            label: 'Tất cả',
            icon: Icons.all_inclusive,
            filter: 'all',
          ),
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Expanded(
          child: _buildFilterChip(
            label: 'Đã nhận',
            icon: Icons.check_circle_outline,
            filter: 'da-nhan',
          ),
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Expanded(
          child: _buildFilterChip(
            label: 'Đang tiến hành',
            icon: Icons.pending_outlined,
            filter: 'dang-tien-hanh',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required String filter,
  }) {
    final isSelected = _selectedFilter == filter;
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
          // Load lại data với filter mới
          context.read<PhuHuynhProvider>().loadQuaDaNhan(
            widget.treEmId,
            filter: filter,
          );
        },
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
        child: Container(
          padding: AppDimensions.paddingSymmetric(
            vertical: AppDimensions.spacingSM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSM,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
              SizedBox(width: AppDimensions.spacingXXS),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredList() {
    if (widget.quaData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: AppDimensions.iconXXL,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: AppDimensions.spacingSM),
            Text(
              'Chưa có dữ liệu',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final quaList = widget.quaData!.danhSachQua;

    if (quaList.isEmpty) {
      return _buildEmptyStateForFilter();
    }

    return ListView.builder(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingXS,
      ),
      itemCount: quaList.length,
      itemBuilder: (context, index) {
        return _buildQuaCard(quaList[index]);
      },
    );
  }

  Widget _buildEmptyStateForFilter() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'da-nhan':
        message = 'Chưa nhận quà nào';
        icon = Icons.inbox_outlined;
        break;
      case 'dang-tien-hanh':
        message = 'Không có quà đang chờ';
        icon = Icons.hourglass_empty;
        break;
      default:
        message = 'Chưa có quà nào';
        icon = Icons.card_giftcard;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXXL,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppDimensions.spacingSM),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // QUÀ CARD
  // ==========================================================================
  Widget _buildQuaCard(QuaPhanPhatInfo qua) {
    final baseUrl = 'http://10.0.2.2:5035';

    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: AppColors.accent,
            width: AppDimensions.borderExtraThick,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        ),
        padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Tên quà + Status
            Row(
              children: [
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.accentOverlay,
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusSM,
                    ),
                  ),
                  child: Icon(
                    Icons.redeem,
                    color: AppColors.accent,
                    size: AppDimensions.iconMD,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qua.tenQua,
                        style: AppTextStyles.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Người phân phát: ${qua.nguoiPhanPhat}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),
                _buildTrangThaiChip(qua.trangThai),
              ],
            ),

            // Divider
            Divider(
              height: AppDimensions.spacingLG,
              color: AppColors.divider,
              thickness: AppDimensions.dividerThickness,
            ),

            // Mô tả
            if (qua.moTa.isNotEmpty) ...[
              Text(
                qua.moTa,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppDimensions.spacingSM),
            ],

            // Số lượng và Ngày nhận
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: AppDimensions.paddingSymmetric(
                      horizontal: AppDimensions.spacingSM,
                      vertical: AppDimensions.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.infoOverlay,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_basket,
                          size: AppDimensions.iconSM,
                          color: AppColors.info,
                        ),
                        SizedBox(width: AppDimensions.spacingXS),
                        Text(
                          'Số lượng: ${qua.soLuongNhan}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),
                Expanded(
                  child: Container(
                    padding: AppDimensions.paddingSymmetric(
                      horizontal: AppDimensions.spacingSM,
                      vertical: AppDimensions.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successOverlay,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppDimensions.iconSM - 2,
                          color: AppColors.success,
                        ),
                        SizedBox(width: AppDimensions.spacingXS),
                        Flexible(
                          child: Text(
                            qua.ngayPhanPhat,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacingSM),

            // Xem ảnh quà
            if (qua.anh.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        imageUrl: '$baseUrl${qua.anh}',
                        title: qua.tenQua,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.image,
                  size: AppDimensions.iconSM,
                  color: AppColors.accent,
                ),
                label: Text(
                  'Xem ảnh quà',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: AppDimensions.paddingSymmetric(
                    horizontal: AppDimensions.spacingSM,
                    vertical: AppDimensions.spacingXS,
                  ),
                  backgroundColor: AppColors.accentOverlay,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusSM,
                    ),
                  ),
                ),
              ),

            // Thông tin sự kiện
            if (qua.suKienID != null) ...[
              SizedBox(height: AppDimensions.spacingSM),
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.primaryOverlay,
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusSM,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: AppDimensions.iconSM,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppDimensions.spacingXS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sự kiện liên quan',
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            qua.tenSuKien ?? 'Không có tên',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChiTietSuKienScreen(
                              suKienId: qua.suKienID!,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: AppDimensions.iconXS,
                        color: AppColors.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Xem chi tiết sự kiện',
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: AppDimensions.spacingSM),
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusSM,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: AppDimensions.iconSM,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppDimensions.spacingXS),
                    Text(
                      'Không có sự kiện liên quan',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TRẠNG THÁI CHIP
  // ==========================================================================
  Widget _buildTrangThaiChip(String trangThai) {
    Color color;
    IconData icon;

    if (trangThai.toLowerCase().contains('đã nhận')) {
      color = AppColors.success;
      icon = Icons.check_circle;
    } else {
      // Đang tiến hành, Chờ nhận, etc.
      color = AppColors.warning;
      icon = Icons.pending;
    }

    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.chipPaddingH,
        vertical: AppDimensions.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: AppDimensions.spacingXXS),
          Text(
            trangThai,
            style: AppTextStyles.chip,
          ),
        ],
      ),
    );
  }
}