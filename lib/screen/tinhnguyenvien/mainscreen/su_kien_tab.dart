// screens/tinh_nguyen_vien/event_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/tab_su_kien_tnv.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../detailsscreen/chi_tiet_su_kien.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class EventTab extends StatefulWidget {
  const EventTab({Key? key}) : super(key: key);

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<Map<String, dynamic>> _filters = [
    {
      'key': 'TatCa',
      'label': 'Tất cả',
      'icon': Icons.event,
    },
    {
      'key': 'DuocPhanCong',
      'label': 'Được phân công',
      'icon': Icons.assignment_turned_in,
    },
    {
      'key': 'CoTheDangKy',
      'label': 'Có thể đăng ký',
      'icon': Icons.event_available,
    },
    {
      'key': 'DaDangKy',
      'label': 'Đã đăng ký',
      'icon': Icons.how_to_reg,
    },
    {
      'key': 'DaHetHan',
      'label': 'Đã hết hạn',
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
      context.read<VolunteerProvider>().loadDanhSachSuKien();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = _filters[_tabController.index]['key']!;
      context.read<VolunteerProvider>().changeSuKienFilter(filter);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more if needed
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<VolunteerProvider>().searchSuKien(query);
  }

  Future<void> _onRefresh() async {
    await context.read<VolunteerProvider>().loadDanhSachSuKien();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingSM,
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sự kiện...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: AppDimensions.iconMD,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: AppDimensions.iconSM,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                        setState(() {});
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(AppDimensions.inputRadius),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(AppDimensions.inputRadius),
                      borderSide: BorderSide(
                        color: AppColors.divider,
                        width: AppDimensions.borderThin,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(AppDimensions.inputRadius),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: AppDimensions.borderMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMD,
                      vertical: AppDimensions.spacingSM,
                    ),
                  ),
                  onChanged: (value) {
                    _onSearch(value);
                    setState(() {});
                  },
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textOnPrimary,
                indicatorWeight: 3,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
                labelStyle: AppTextStyles.labelMedium,
                isScrollable: true,
                tabs: _filters.map((filter) {
                  return Tab(
                    icon: Icon(
                      filter['icon'] as IconData,
                      size: AppDimensions.iconSM,
                    ),
                    text: filter['label'] as String,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingSuKien && provider.danhSachSuKien.isEmpty) {
            return _buildShimmerLoading();
          }

          if (provider.errorMessageSuKien != null &&
              provider.danhSachSuKien.isEmpty) {
            return _buildErrorState(provider.errorMessageSuKien!);
          }

          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: _buildEventList(provider, filter['key']!),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // EVENT LIST
  // ==========================================================================
  Widget _buildEventList(VolunteerProvider provider, String filter) {
    final list = provider.danhSachSuKien;

    if (list.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final event = list[index];
        return _buildEventCard(event);
      },
    );
  }

  // ==========================================================================
  // EVENT CARD
  // ==========================================================================
  Widget _buildEventCard(SuKienListDto event) {
    final DateTime? startDate = _parseDate(event.ngayBatDau);
    final DateTime? endDate = _parseDate(event.ngayKetThuc);
    final bool isExpired = event.daHetHan;
    final bool isFull = event.daDay;
    final bool isUpcoming =
        startDate != null && startDate.isAfter(DateTime.now());
    final bool isWithin7Days = isUpcoming &&
        startDate.difference(DateTime.now()).inDays <= 7;

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
                    EventDetailScreen(suKienId: event.suKienId),
              ),
            );
          },
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với gradient
              _buildCardHeader(event, isExpired),

              // Nội dung chi tiết
              Padding(
                padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thời gian
                    _buildInfoRow(
                      Icons.access_time,
                      '${_formatDate(event.ngayBatDau)} - ${_formatDate(event.ngayKetThuc)}',
                      AppColors.info,
                    ),
                    SizedBox(height: AppDimensions.spacingSM),

                    // Địa điểm
                    _buildInfoRow(
                      Icons.location_on,
                      event.diaDiem,
                      AppColors.error,
                    ),
                    SizedBox(height: AppDimensions.spacingSM),

                    // Số lượng TNV
                    _buildInfoRow(
                      Icons.people_outline,
                      '${event.soLuongDaDangKy}/${event.soLuongTinhNguyenVien} tình nguyện viên',
                      AppColors.secondary,
                    ),

                    // Công việc phân công (nếu có)
                    if (event.congViecPhanCong != null) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildInfoRow(
                        Icons.work_outline,
                        event.congViecPhanCong!,
                        AppColors.accent,
                      ),
                    ],

                    // Countdown nếu sắp diễn ra
                    if (isWithin7Days && startDate != null) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildCountdown(startDate),
                    ],

                    // Badge "Đã kết thúc"
                    if (isExpired) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildEndedBadge(),
                    ],

                    // Badge "Đã đủ TNV"
                    if (isFull && !isExpired && !event.daDangKy && !event.daPhanCong) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildFullBadge(),
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
  Widget _buildCardHeader(SuKienListDto event, bool isExpired) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(event, isExpired),
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

          // Status Badges (top right)
          Positioned(
            top: AppDimensions.spacingSM,
            right: AppDimensions.spacingSM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (event.daPhanCong)
                  _buildStatusBadge(
                    'Được phân công',
                    AppColors.success,
                    Icons.check_circle,
                  ),
                if (event.daDangKy && event.trangThaiDangKy != null) ...[
                  if (event.daPhanCong) SizedBox(height: AppDimensions.spacingXS),
                  _buildStatusBadge(
                    event.trangThaiDangKy!,
                    _getStatusColor(event.trangThaiDangKy!),
                    _getStatusIcon(event.trangThaiDangKy!),
                  ),
                ],
              ],
            ),
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
                    _getMainIcon(event, isExpired),
                    size: AppDimensions.iconLG,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.tenSuKien,
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
                      SizedBox(height: AppDimensions.spacingXXS),
                      // Khu phố badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingXS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withOpacity(0.2),
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusSM,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_city,
                              size: AppDimensions.iconXS,
                              color: AppColors.textOnPrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              event.tenKhuPho,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  List<Color> _getGradientColors(SuKienListDto event, bool isExpired) {
    if (isExpired) {
      return [
        AppColors.textDisabled,
        AppColors.textDisabled.withOpacity(0.7),
      ];
    }

    if (event.daPhanCong) {
      return [
        AppColors.success,
        AppColors.successDark,
      ];
    }

    if (event.daDangKy) {
      return [
        AppColors.info,
        AppColors.infoDark,
      ];
    }

    if (event.daDay) {
      return [
        AppColors.warning,
        AppColors.warningDark,
      ];
    }

    return [
      AppColors.primary,
      AppColors.primaryDark,
    ];
  }

  // ==========================================================================
  // MAIN ICON
  // ==========================================================================
  IconData _getMainIcon(SuKienListDto event, bool isExpired) {
    if (isExpired) return Icons.event_busy;
    if (event.daPhanCong) return Icons.assignment_turned_in;
    if (event.daDangKy) return Icons.how_to_reg;
    if (event.daDay) return Icons.event_busy;
    return Icons.event_available;
  }

  // ==========================================================================
  // STATUS BADGE
  // ==========================================================================
  Widget _buildStatusBadge(String label, Color color, IconData icon) {
    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
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
  // FULL BADGE
  // ==========================================================================
  Widget _buildFullBadge() {
    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.warning,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group,
            size: AppDimensions.iconSM,
            color: AppColors.warning,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Text(
            'Đã đủ TNV',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.warning,
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
      case 'DuocPhanCong':
        message = 'Chưa có sự kiện được phân công';
        icon = Icons.assignment_turned_in;
        iconColor = AppColors.success;
        break;
      case 'CoTheDangKy':
        message = 'Không có sự kiện có thể đăng ký';
        icon = Icons.event_available;
        iconColor = AppColors.info;
        break;
      case 'DaDangKy':
        message = 'Bạn chưa đăng ký sự kiện nào';
        icon = Icons.how_to_reg;
        iconColor = AppColors.info;
        break;
      case 'DaHetHan':
        message = 'Chưa có sự kiện đã hết hạn';
        icon = Icons.event_busy;
        iconColor = AppColors.textDisabled;
        break;
      default:
        message = _searchController.text.isNotEmpty
            ? 'Không tìm thấy sự kiện phù hợp'
            : 'Chưa có sự kiện nào';
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
          if (_searchController.text.isNotEmpty) ...[
            SizedBox(height: AppDimensions.spacingXS),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
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
              onPressed: () =>
                  context.read<VolunteerProvider>().loadDanhSachSuKien(),
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
  // HELPER METHODS
  // ==========================================================================
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return AppColors.success;
      case 'Chờ duyệt':
        return AppColors.warning;
      case 'Từ chối':
        return AppColors.error;
      default:
        return AppColors.textDisabled;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Đã duyệt':
        return Icons.check_circle;
      case 'Chờ duyệt':
        return Icons.schedule;
      case 'Từ chối':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  DateTime? _parseDate(DateTime? date) {
    return date;
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