// import 'package:flutter/material.dart';
//
// class VolunteerHomeTab extends StatelessWidget {
//   final Map<String, dynamic> user;
//
//   const VolunteerHomeTab({Key? key, required this.user}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final tnv = MockData.tinhNguyenVien.firstWhere(
//           (t) => t['userId'] == user['userId'],
//       orElse: () => {},
//     );
//
//     final phanCong = MockData.suKienPhanCong
//         .where((p) => p['tinhNguyenVienId'] == tnv['tinhNguyenVienId'])
//         .take(3)
//         .toList();
//
//     final unreadCount = MockData.thongBaoTNV.where((t) => !t['daDoc']).length;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trang chủ'),
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications),
//                 onPressed: () {},
//               ),
//               if (unreadCount > 0)
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       '$unreadCount',
//                       style: const TextStyle(color: Colors.white, fontSize: 10),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thông tin cá nhân
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 30,
//                       child: Icon(Icons.person, size: 32),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             user['hoTen'],
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             tnv['chucVu'] ?? 'Tình nguyện viên',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Tình trạng phân phát',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Chọn tình trạng',
//               ),
//               value: _selectedStatus,
//               items: _statusOptions
//                   .map((status) => DropdownMenuItem(
//                 value: status,
//                 child: Text(status),
//               ))
//                   .toList(),
//               onChanged: (value) {
//                 setState(() => _selectedStatus = value);
//               },
//             ),
//             if (showDatePicker) ...[
//               const SizedBox(height: 16),
//               const Text(
//                 'Hẹn lại ngày giao',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               InkWell(
//                 onTap: () async {
//                   final date = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                   );
//                   if (date != null) {
//                     setState(() => _selectedDate = date);
//                   }
//                 },
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.calendar_today),
//                   ),
//                   child: Text(
//                     _selectedDate == null
//                         ? 'Chọn ngày'
//                         : DateFormat('dd/MM/yyyy').format(_selectedDate!),
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 16),
//             const Text(
//               'Ghi chú thêm',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _noteController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Nhập ghi chú...',
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Text(
//                   'Chụp ảnh minh chứng',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const Text(
//                   ' *',
//                   style: TextStyle(color: Colors.red, fontSize: 16),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       setState(() => _imagePath = 'camera_image.jpg');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Chụp ảnh từ máy ảnh')),
//                       );
//                     },
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Máy ảnh'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       setState(() => _imagePath = 'gallery_image.jpg');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Chọn ảnh từ thư viện')),
//                       );
//                     },
//                     icon: const Icon(Icons.photo_library),
//                     label: const Text('Thư viện'),
//                   ),
//                 ),
//               ],
//             ),
//             if (_imagePath != null) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: Colors.green),
//                     const SizedBox(width: 8),
//                     Expanded(child: Text('Đã chọn: $_imagePath')),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () {
//                         setState(() => _imagePath = null);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Hủy'),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_selectedStatus == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('Vui lòng chọn tình trạng')),
//                       );
//                       return;
//                     }
//                     if (_imagePath == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('Vui lòng chụp ảnh minh chứng')),
//                       );
//                       return;
//                     }
//                     if (showDatePicker && _selectedDate == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('Vui lòng chọn ngày hẹn lại')),
//                       );
//                       return;
//                     }
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Cập nhật phân phát thành công'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Gửi'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }