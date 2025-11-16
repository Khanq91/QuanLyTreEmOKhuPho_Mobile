// screens/tinh_nguyen_vien/lich_trong_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/dashboard_tnv.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class LichTrongScreen extends StatefulWidget {
  const LichTrongScreen({Key? key}) : super(key: key);

  @override
  State<LichTrongScreen> createState() => _LichTrongScreenState();
}

class _LichTrongScreenState extends State<LichTrongScreen> {
  List<ChiTietLichTrongModel> _editableSchedule = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLichTrong();
    });
  }

  void _loadLichTrong() {
    final provider = Provider.of<VolunteerProvider>(context, listen: false);
    if (provider.lichTrong != null) {
      setState(() {
        _editableSchedule = List.from(
          provider.lichTrong!.chiTietLichTrong.map((ct) => ct.copyWith()),
        );
      });
    }
  }

  void _toggleSlot(String thu, String buoi) {
    setState(() {
      final index = _editableSchedule.indexWhere(
            (ct) => ct.thu == thu && ct.buoi == buoi,
      );
      if (index != -1) {
        _editableSchedule[index] = _editableSchedule[index].copyWith(
          isAvailable: !_editableSchedule[index].isAvailable,
        );
        _hasChanges = true;
      }
    });
  }

  Future<void> _saveLichTrong() async {
    final provider = Provider.of<VolunteerProvider>(context, listen: false);

    try {
      final lichTrong = LichTrongModel(
        lichTrongId: provider.lichTrong?.lichTrongId,
        isEmpty: false,
        chiTietLichTrong: _editableSchedule,
      );

      final success = await provider.updateLichTrong(lichTrong);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Cập nhật lịch trống thành công'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            margin: EdgeInsets.all(AppDimensions.spacingMD),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Cập nhật lịch trống thất bại'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            margin: EdgeInsets.all(AppDimensions.spacingMD),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi: $e')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          margin: EdgeInsets.all(AppDimensions.spacingMD),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
        ),
        title: Text('Xác nhận', style: AppTextStyles.headingMedium),
        content: Text(
          'Bạn có thay đổi chưa lưu. Bạn có muốn thoát?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLG,
                vertical: AppDimensions.spacingSM,
              ),
            ),
            child: Text(
              'Ở lại',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLG,
                vertical: AppDimensions.spacingSM,
              ),
            ),
            child: Text(
              'Thoát',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Cập nhật lịch trống', style: AppTextStyles.appBarTitle),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.appBarBackground,
          iconTheme: const IconThemeData(color: AppColors.appBarText),
        ),
        body: Consumer<VolunteerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && _editableSchedule.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingLG),
                    Text(
                      'Đang tải lịch trống...',
                      style: AppTextStyles.bodyMediumSecondary,
                    ),
                  ],
                ),
              );
            }

            // Empty State
            if (_editableSchedule.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingXXL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: AppDimensions.iconXXL,
                        color: AppColors.textDisabled,
                      ),
                      SizedBox(height: AppDimensions.spacingLG),
                      Text(
                        'Chưa có lịch trống',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Hãy tạo lịch trống để cán bộ biết khi nào bạn rảnh',
                        style: AppTextStyles.bodyMediumSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Instructions
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOverlay,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                        width: AppDimensions.borderThin,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: AppColors.primary,
                            size: AppDimensions.iconSM,
                          ),
                          SizedBox(width: AppDimensions.spacingXS),
                          Text('Hướng dẫn', style: AppTextStyles.headingSmall),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingSM),
                      _buildInstructionItem(
                        '• Nhấn vào ô để đánh dấu thời gian bạn rảnh',
                      ),
                      SizedBox(height: AppDimensions.spacingXXS),
                      _buildInstructionItem(
                        '• Ô xanh: Rảnh - Ô trắng: Bận',
                      ),
                      SizedBox(height: AppDimensions.spacingXXS),
                      _buildInstructionItem(
                        '• Lịch này giúp cán bộ tham khảo khi phân công',
                      ),
                    ],
                  ),
                ),

                // Schedule Grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppDimensions.spacingMD),
                    child: _buildScheduleGrid(),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.buttonPaddingV,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.buttonRadius,
                                ),
                              ),
                              side: BorderSide(
                                color: AppColors.primary,
                                width: AppDimensions.borderMedium,
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: provider.isLoading ? null : _saveLichTrong,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.buttonPaddingV,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.buttonRadius,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.5),
                            ),
                            icon: provider.isLoading
                                ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textOnPrimary,
                                ),
                              ),
                            )
                                : Icon(
                              Icons.check,
                              size: AppDimensions.iconSM,
                              color: AppColors.textOnPrimary,
                            ),
                            label: Text(
                              'Lưu lịch trống',
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildScheduleGrid() {
    final days = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];
    final sessions = ['Sáng', 'Chiều', 'Tối'];

    return Card(
      elevation: AppDimensions.elevationXS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                SizedBox(width: 60),
                ...days.map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day == 'Chủ nhật' ? 'CN' : day.substring(5),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )),
              ],
            ),
            Divider(
              height: AppDimensions.spacingXL,
              thickness: AppDimensions.dividerThickness,
              color: AppColors.divider,
            ),

            // Grid
            ...sessions.map((session) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.spacingSM),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        session,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...days.map((day) {
                      final chiTiet = _editableSchedule.firstWhere(
                            (ct) => ct.thu == day && ct.buoi == session,
                        orElse: () => ChiTietLichTrongModel(
                          thu: day,
                          buoi: session,
                          isAvailable: false,
                        ),
                      );

                      return Expanded(
                        child: Center(
                          child: InkWell(
                            onTap: () => _toggleSlot(day, session),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: chiTiet.isAvailable
                                    ? AppColors.success
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                                border: Border.all(
                                  color: chiTiet.isAvailable
                                      ? AppColors.success
                                      : AppColors.divider,
                                  width: AppDimensions.borderThick,
                                ),
                              ),
                              child: chiTiet.isAvailable
                                  ? Icon(
                                Icons.check,
                                color: AppColors.textOnPrimary,
                                size: AppDimensions.iconMD,
                              )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

            SizedBox(height: AppDimensions.spacingMD),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(AppColors.success, 'Rảnh', true),
                SizedBox(width: AppDimensions.spacingXL),
                _buildLegend(AppColors.surface, 'Bận', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, bool isAvailable) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: isAvailable ? AppColors.success : AppColors.divider,
              width: AppDimensions.borderThick,
            ),
          ),
          child: isAvailable
              ? Icon(
            Icons.check,
            color: AppColors.textOnPrimary,
            size: AppDimensions.iconXS,
          )
              : null,
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}