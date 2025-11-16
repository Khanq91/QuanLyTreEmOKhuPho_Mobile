import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../models/tab_su_kien_ph.dart';
import '../../../providers/phu_huynh.dart';
import '../detailsscreen/chi_tiet_su_kien_sk_screen.dart';

class SuKienScreen extends StatefulWidget {
  const SuKienScreen({Key? key}) : super(key: key);

  @override
  State<SuKienScreen> createState() => _SuKienScreenState();
}

class _SuKienScreenState extends State<SuKienScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<Map<String, dynamic>> _filters = [
    {
      'key': 'sap-dien-ra',
      'label': 'Sắp diễn ra',
      'icon': Icons.event_available,
    },
    {
      'key': 'da-dang-ky',
      'label': 'Đã đăng ký',
      'icon': Icons.how_to_reg,
    },
    {
      'key': 'da-ket-thuc',
      'label': 'Đã kết thúc',
      'icon': Icons.event_busy,
    },
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sự kiện', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.appBarElevation,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnPrimary,
          indicatorWeight: 3,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
          labelStyle: AppTextStyles.labelLarge,
          tabs: _filters.map((filter) {
            return Tab(
              icon: Icon(
                // filter['icon'] as IconData,
                filter['icon'] is IconData ? filter['icon'] : Icons.help_outline,
                size: AppDimensions.iconSM,
              ),
              text: filter['label'] as String,
            );
          }).toList(),
        ),
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.danhSachSuKien.isEmpty) {
            return _buildShimmerLoading();
          }

          if (provider.errorMessage != null &&
              provider.danhSachSuKien.isEmpty) {
            return _buildErrorState(provider.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: _buildSuKienList(provider, filter['key']!),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // SỰ KIỆN LIST
  // ==========================================================================
  Widget _buildSuKienList(PhuHuynhProvider provider, String filter) {
    final list = provider.danhSachSuKien;

    if (list.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: list.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return Center(
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }

        final suKien = list[index];
        return _buildSuKienCard(suKien);
      },
    );
  }

  // ==========================================================================
  // SỰ KIỆN CARD
  // ==========================================================================
  Widget _buildSuKienCard(DanhSachSuKien suKien) {
    final DateTime? startDate = _parseDate(suKien.ngayBatDau);
    final DateTime? endDate = _parseDate(suKien.ngayKetThuc);
    final bool isUpcoming =
        startDate != null && startDate.isAfter(DateTime.now());
    final bool isWithin7Days = isUpcoming &&
        startDate.difference(DateTime.now()).inDays <= 7;
    final bool isEnded = endDate != null && endDate.isBefore(DateTime.now());

    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                builder: (context) =>
                    ChiTietSuKienScreen(suKienId: suKien.suKienId),
              ),
            );
          },
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với gradient và status badge
              _buildCardHeader(suKien, isEnded),

              // Nội dung chi tiết
              Padding(
                padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thời gian
                    _buildInfoRow(
                      Icons.access_time,
                      '${suKien.ngayBatDau} - ${suKien.ngayKetThuc}',
                      AppColors.info,
                    ),
                    SizedBox(height: AppDimensions.spacingSM),

                    // Địa điểm
                    _buildInfoRow(
                      Icons.location_on,
                      suKien.diaDiem ?? 'Chưa có thông tin',
                      AppColors.error,
                    ),
                    SizedBox(height: AppDimensions.spacingSM),

                    // Khu phố
                    _buildInfoRow(
                      Icons.home_work,
                      suKien.tenKhuPho ?? 'Chưa có thông tin',
                      AppColors.secondary,
                    ),

                    // Countdown nếu sắp diễn ra
                    if (isWithin7Days && startDate != null) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildCountdown(startDate),
                    ],

                    // Badge "Đã kết thúc"
                    if (isEnded) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildEndedBadge(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CARD HEADER
  // ==========================================================================
  Widget _buildCardHeader(DanhSachSuKien suKien, bool isEnded) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(suKien, isEnded),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.cardRadius),
          topRight: Radius.circular(AppDimensions.cardRadius),
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
              top: AppDimensions.spacingSM,
              right: AppDimensions.spacingSM,
              child: _buildStatusBadge(suKien.trangThaiDangKy),
            ),

          // Icon và Tên sự kiện
          Positioned(
            bottom: AppDimensions.spacingSM,
            left: AppDimensions.spacingMD,
            right: AppDimensions.spacingMD,
            child: Row(
              children: [
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusMD,
                    ),
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: AppDimensions.iconLG,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  child: Text(
                    suKien.tenSuKien,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      shadows: [
                        const Shadow(
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
    );
  }

  // ==========================================================================
  // GRADIENT COLORS
  // ==========================================================================
  List<Color> _getGradientColors(DanhSachSuKien suKien, bool isEnded) {
    if (isEnded) {
      return [
        AppColors.textDisabled,
        AppColors.textDisabled.withOpacity(0.7),
      ];
    }

    if (suKien.daDangKy) {
      return [
        AppColors.success,
        AppColors.successDark,
      ];
    }

    return [
      AppColors.info,
      AppColors.infoDark,
    ];
  }

  // ==========================================================================
  // STATUS BADGE
  // ==========================================================================
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'chờ duyệt':
        bgColor = AppColors.warning;
        icon = Icons.schedule;
        label = 'Chờ duyệt';
        break;
      case 'đã duyệt':
        bgColor = AppColors.success;
        icon = Icons.check_circle;
        label = 'Đã duyệt';
        break;
      case 'từ chối':
        bgColor = AppColors.error;
        icon = Icons.cancel;
        label = 'Từ chối';
        break;
      default:
        bgColor = AppColors.textDisabled;
        icon = Icons.help_outline;
        label = status;
    }

    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
            label,
            style: AppTextStyles.chip,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INFO ROW
  // ==========================================================================
  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconSM,
            color: iconColor,
          ),
        ),
        SizedBox(width: AppDimensions.spacingSM),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // COUNTDOWN BADGE
  // ==========================================================================
  Widget _buildCountdown(DateTime targetDate) {
    final duration = targetDate.difference(DateTime.now());
    final days = duration.inDays;
    final hours = duration.inHours % 24;

    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accentDark,
          ],
        ),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: AppDimensions.iconSM,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Text(
            days > 0
                ? 'Còn $days ngày $hours giờ'
                : 'Còn $hours giờ ${duration.inMinutes % 60} phút',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ENDED BADGE
  // ==========================================================================
  Widget _buildEndedBadge() {
    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.textDisabled.withOpacity(0.2),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.textDisabled,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: AppDimensions.iconSM,
            color: AppColors.textDisabled,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Text(
            'Đã kết thúc',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textDisabled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EMPTY STATE
  // ==========================================================================
  Widget _buildEmptyState(String filter) {
    String message;
    IconData icon;
    Color iconColor;

    switch (filter) {
      case 'sap-dien-ra':
        message = 'Chưa có sự kiện sắp diễn ra';
        icon = Icons.event_available;
        iconColor = AppColors.info;
        break;
      case 'da-dang-ky':
        message = 'Bạn chưa đăng ký sự kiện nào';
        icon = Icons.how_to_reg;
        iconColor = AppColors.success;
        break;
      case 'da-ket-thuc':
        message = 'Chưa có sự kiện đã kết thúc';
        icon = Icons.event_busy;
        iconColor = AppColors.textDisabled;
        break;
      default:
        message = 'Không có sự kiện';
        icon = Icons.event;
        iconColor = AppColors.textDisabled;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconXXL,
              color: iconColor,
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHIMMER LOADING
  // ==========================================================================
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.radiusCircular(
              AppDimensions.cardRadius,
            ),
          ),
          child: Column(
            children: [
              // Header placeholder
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.cardRadius),
                    topRight: Radius.circular(AppDimensions.cardRadius),
                  ),
                ),
              ),
              // Content placeholder
              Padding(
                padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusXS,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingSM),
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusXS,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Container(
                      height: 16,
                      width: 250,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusXS,
                        ),
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

  // ==========================================================================
  // ERROR STATE
  // ==========================================================================
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.errorOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: AppDimensions.iconXXL,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppDimensions.spacingMD),
            Text(
              'Đã xảy ra lỗi',
              style: AppTextStyles.headingMedium,
            ),
            SizedBox(height: AppDimensions.spacingXS),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXL),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh, size: AppDimensions.iconSM),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.buttonRadius,
                  ),
                ),
                elevation: AppDimensions.elevationSM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER
  // ==========================================================================
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// CUSTOM PAINTER FOR BACKGROUND PATTERN
// ============================================================================
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textOnPrimary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Vẽ các hình tròn trang trí
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