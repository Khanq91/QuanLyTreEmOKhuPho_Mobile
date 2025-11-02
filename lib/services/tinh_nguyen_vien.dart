// import '../models/dashboard_tnv.dart';
// import '../models/lich_trong.dart';
// import '../models/su_kien.dart';
// import '../models/thong_bao.dart';
// import '../models/tre_em.dart';
// import 'api.dart';
//
// // GET  /mobile/tinh-nguyen-vien/dashboard
// // GET  /mobile/tinh-nguyen-vien/su-kien
// // GET  /mobile/tinh-nguyen-vien/lich-trong
// // POST /mobile/tinh-nguyen-vien/lich-trong
// // GET  /mobile/tinh-nguyen-vien/tre-em?loai=VanDong
// // GET  /mobile/tinh-nguyen-vien/tre-em?loai=HoTro
// // POST /mobile/tinh-nguyen-vien/van-dong
// // POST /mobile/tinh-nguyen-vien/ho-tro/:id/cap-nhat
// // GET  /mobile/tinh-nguyen-vien/thong-bao
// // PUT  /mobile/tinh-nguyen-vien/thong-bao/:id/da-doc
//
// class VolunteerService extends ApiService {
//   // Dashboard
//   Future<DashboardTinhNguyenVien> getDashboard() async {
//     return Get(
//       '/mobile/tinh-nguyen-vien/dashboard',
//           (response) => DashboardTinhNguyenVien.fromJson(response),
//     );
//   }
//
//   // Danh sách sự kiện
//   Future<List<SuKien>> getSuKien({String? boLoc}) async {
//     final endpoint = boLoc != null
//         ? '/mobile/tinh-nguyen-vien/su-kien?boLoc=$boLoc'
//         : '/mobile/tinh-nguyen-vien/su-kien';
//
//     return Get(
//       endpoint,
//           (response) {
//         final list = response is List ? response : response['items'] as List;
//         return list.map((item) => SuKien.fromJson(item)).toList();
//       },
//     );
//   }
//
//   // Chi tiết sự kiện
//   Future<SuKien> getChiTietSuKien(int suKienId) async {
//     return Get(
//       '/SuKien/$suKienId',
//           (response) => SuKien.fromJson(response),
//     );
//   }
//
//   // Đăng ký sự kiện
//   Future<bool> dangKySuKien(int suKienId) async {
//     return Post(
//       '/mobile/tinh-nguyen-vien/su-kien/$suKienId/dang-ky',
//       {'loaiNguoiDangKy': 'TinhNguyenVien'},
//           (response) => response['success'] ?? true,
//     );
//   }
//
//   // Check-in sự kiện (QR Code)
//   Future<bool> checkInSuKien(int suKienId) async {
//     return Post(
//       '/mobile/tinh-nguyen-vien/su-kien/$suKienId/check-in',
//       {},
//           (response) => response['success'] ?? true,
//     );
//   }
//
//   // Lấy lịch trống
//   Future<List<LichTrong>> getLichTrong() async {
//     return Get(
//       '/mobile/tinh-nguyen-vien/lich-trong',
//           (response) {
//         final list = response is List ? response : response['items'] as List;
//         return list.map((item) => LichTrong.fromJson(item)).toList();
//       },
//     );
//   }
//
//   // Cập nhật lịch trống
//   Future<bool> capNhatLichTrong({
//     required DateTime tuanBatDau,
//     required List<String> buoiTrong,
//   }) async {
//     return Post(
//       '/mobile/tinh-nguyen-vien/lich-trong',
//       {
//         'tuanBatDau': tuanBatDau.toIso8601String(),
//         'buoiTrong': buoiTrong,
//       },
//           (response) => response['success'] ?? true,
//     );
//   }
//
//   // Lấy danh sách trẻ em cần vận động
//   Future<List<TreEm>> getTreEmVanDong() async {
//     return Get(
//       '/mobile/tinh-nguyen-vien/tre-em?loai=VanDong',
//           (response) {
//         final list = response is List ? response : response['items'] as List;
//         return list.map((item) => TreEm.fromJson(item)).toList();
//       },
//     );
//   }
//
//   // Lấy danh sách trẻ em nhận hỗ trợ
//   Future<List<TreEm>> getTreEmHoTro() async {
//     return Get(
//       '/mobile/tinh-nguyen-vien/tre-em?loai=HoTro',
//           (response) {
//         final list = response is List ? response : response['items'] as List;
//         return list.map((item) => TreEm.fromJson(item)).toList();
//       },
//     );
//   }
//
//   // Cập nhật tình trạng trẻ em vận động
//   Future<bool> capNhatTinhTrangVanDong({
//     required int treEmId,
//     required String tinhTrang,
//     required String lyDo,
//     String? ghiChu,
//     String? anhMinhChung,
//   }) async {
//     return Post(
//       '/mobile/tinh-nguyen-vien/van-dong',
//       {
//         'treEmId': treEmId,
//         'loaiVanDong': 'KhongBoHoc',
//         'ketQua': tinhTrang,
//         'lyDo': lyDo,
//         'ghiChu': ghiChu,
//         'anhMinhChung': anhMinhChung,
//       },
//           (response) => response['success'] ?? true,
//     );
//   }
//
//   // Cập nhật tình trạng phát hỗ trợ
//   Future<bool> capNhatTinhTrangHoTro({
//     required int hoTroId,
//     required String tinhTrang,
//     DateTime? ngayHenTai,
//     String? ghiChu,
//     required String anhMinhChung,
//   }) async {
//     return Post(
//       '/mobile/tinh-nguyen-vien/ho-tro/$hoTroId/cap-nhat',
//       {
//         'tinhTrang': tinhTrang,
//         'ngayHenTai': ngayHenTai?.toIso8601String(),
//         'ghiChu': ghiChu,
//         'anhMinhChung': anhMinhChung,
//       },
//           (response) => response['success'] ?? true,
//     );
//   }
//
//   // Lịch sử hoạt động
//   Future<Map<String, dynamic>> getLichSuHoatDong() async {
//     return Get(
//       '/mobile/tinh-nguyen-vien/lich-su-hoat-dong',
//           (response) => response is Map<String, dynamic>
//           ? response
//           : {'suKien': [], 'hoTro': [], 'vanDong': []},
//     );
//   }
//
//   // Thông báo
//   Future<List<ThongBao>> getThongBao() async {
//     return Get(
//       '/mobile/tinh-nguyen-vien/thong-bao',
//           (response) {
//         final list = response is List ? response : response['items'] as List;
//         return list.map((item) => ThongBao.fromJson(item)).toList();
//       },
//     );
//   }
//
//   // Đánh dấu đã đọc thông báo
//   Future<bool> markThongBaoAsRead(int thongBaoId) async {
//     return Put(
//       '/mobile/tinh-nguyen-vien/thong-bao/$thongBaoId/da-doc',
//       {},
//           (response) => response['success'] ?? true,
//     );
//   }
//
//   // Cập nhật thông tin cá nhân
//   Future<bool> updateThongTinCaNhan(Map<String, dynamic> data) async {
//     return Put(
//       '/TinhNguyenVien',
//       data,
//           (response) => response['success'] ?? true,
//     );
//   }
// }