// // screens/tinh_nguyen_vien/notification_tab.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// class NotificationTab extends StatefulWidget {
//   const NotificationTab({Key? key}) : super(key: key);
//
//   @override
//   State<NotificationTab> createState() => _NotificationTabState();
// }
//
// class _NotificationTabState extends State<NotificationTab> {
//   String _selectedFilter = 'TatCa';
//
//   final Map<String, String> _filters = {
//     'TatCa': 'Tất cả',
//     'ChuaDoc': 'Chưa đọc',
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ThongBaoProvider>().loadDanhSachThongBao();
//     });
//   }
//
//   void _onFilterChanged(String? value) {
//     if (value != null) {
//       setState(() => _selectedFilter = value);
//       context.read<ThongBaoProvider>().changeFilter(value);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Thông báo'),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           Consumer<ThongBaoProvider>(
//             builder: (context, provider, child) {
//               if (provider.soLuongChuaDoc > 0) {
//                 return IconButton(
//                   icon: const Icon(Icons.done_all),
//                   onPressed: () => _showMarkAllReadDialog(),
//                   tooltip: 'Đánh dấu tất cả đã đọc',
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilterSection(),
//           Expanded(child: _buildNotificationList()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.grey[50],
//       child: Row(
//         children: _filters.entries.map((entry) {
//           final isSelected = _selectedFilter == entry.key;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: FilterChip(
//               label: Text(entry.value),
//               selected: isSelected,
//               onSelected: (_) => _onFilterChanged(entry.key),
//               backgroundColor: Colors.white,
//               selectedColor: Colors.blue[100],
//               checkmarkColor: Colors.blue[700],
//               labelStyle: TextStyle(
//                 color: isSelected ? Colors.blue[700] : Colors.grey[700],
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildNotificationList() {
//     return Consumer<ThongBaoProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (provider.errorMessage != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                 const SizedBox(height: 16),
//                 const Text('Đã có lỗi xảy ra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Text(provider.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: () => provider.loadDanhSachThongBao(),
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Thử lại'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         if (provider.danhSachThongBao.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   _selectedFilter == 'ChuaDoc' ? 'Không có thông báo chưa đọc' : 'Chưa có thông báo nào',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return RefreshIndicator(
//           onRefresh: () => provider.loadDanhSachThongBao(),
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: provider.danhSachThongBao.length,
//             itemBuilder: (context, index) {
//               final notification = provider.danhSachThongBao[index];
//               return _buildNotificationCard(notification);
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildNotificationCard(ThongBaoDto notification) {
//     final dateFormat = DateFormat('HH:mm dd/MM/yyyy');
//     final isUnread = !notification.daDoc;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: isUnread ? 3 : 1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: isUnread ? Colors.blue[50] : Colors.white,
//       child: InkWell(
//         onTap: () => _handleNotificationTap(notification),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Unread indicator
//                   if (isUnread)
//                     Container(
//                       width: 10,
//                       height: 10,
//                       margin: const EdgeInsets.only(top: 4, right: 12),
//                       decoration: const BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   // Content
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Notification content
//                         Text(
//                           notification.noiDung,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
//                             color: Colors.grey[900],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         // Event name if available
//                         if (notification.tenSuKien != null) ...[
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[100],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.event, size: 14, color: Colors.blue[700]),
//                                 const SizedBox(width: 6),
//                                 Flexible(
//                                   child: Text(
//                                     notification.tenSuKien!,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: Colors.blue[700],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                         // Timestamp
//                         Row(
//                           children: [
//                             Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
//                             const SizedBox(width: 4),
//                             Text(
//                               dateFormat.format(notification.ngayThongBao),
//                               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                             ),
//                             if (notification.ngayBatDauSuKien != null) ...[
//                               const SizedBox(width: 12),
//                               Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
//                               const SizedBox(width: 4),
//                               Text(
//                                 DateFormat('dd/MM/yyyy').format(notification.ngayBatDauSuKien!),
//                                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Arrow icon
//                   if (notification.suKienId != null)
//                     Icon(Icons.chevron_right, color: Colors.grey[400]),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleNotificationTap(ThongBaoDto notification) async {
//     // Mark as read
//     if (!notification.daDoc) {
//       await context.read<ThongBaoProvider>().danhDauDaDoc(notification.thongBaoId);
//     }
//
//     // Navigate to event detail if available
//     if (notification.suKienId != null && mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => EventDetailScreen(suKienId: notification.suKienId!),
//         ),
//       );
//     }
//   }
//
//   void _showMarkAllReadDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Đánh dấu tất cả đã đọc'),
//         content: const Text('Bạn có chắc muốn đánh dấu tất cả thông báo là đã đọc?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Hủy'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await context.read<ThongBaoProvider>().danhDauTatCaDaDoc();
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Đã đánh dấu tất cả đã đọc'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Đồng ý'),
//           ),
//         ],
//       ),
//     );
//   }
// }