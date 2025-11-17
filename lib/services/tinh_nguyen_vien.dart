import 'dart:convert';
import 'dart:io';
import '../models/dashboard_tnv.dart';
import '../models/tab_su_kien_tnv.dart';
import '../models/tab_tai_khoan_tnv.dart';
import '../models/tab_thong_bao_tnv.dart';
import '../models/tab_tre_em_tnv.dart';
import 'api.dart';

class VolunteerService extends ApiService {

  //Dashboard
  Future<TinhNguyenVienHomeModel> getHome() async {
    return Get(
      '/Mobile/TinhNguyenVien/Home',
          (response) => TinhNguyenVienHomeModel.fromJson(response),
    );
  }

  // Lấy lịch trống
  Future<LichTrongModel> getLichTrong() async {
    return Get(
      '/Mobile/TinhNguyenVien/LichTrong',
          (response) => LichTrongModel.fromJson(response),
    );
  }

  // Cập nhật lịch trống
  Future<bool> updateLichTrong(LichTrongModel lichTrong) async {
    return Put(
      '/Mobile/TinhNguyenVien/LichTrong',
      lichTrong.toJson(),
          (response) => response['message'] != null,
    );
  }

  // ==================== SỰ KIỆN ====================

  /// Lấy danh sách sự kiện
  Future<List<SuKienListDto>> getDanhSachSuKien({
    String? filter,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (filter != null && filter != 'TatCa') {
      queryParams['filter'] = filter;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    return Get(
      '/Mobile/TinhNguyenVien/DanhSachSuKien',
          (response) => (response as List)
          .map((item) => SuKienListDto.fromJson(item))
          .toList(),
      queryParams: queryParams,
    );
  }

  /// Lấy chi tiết sự kiện
  Future<SuKienChiTietDto> getChiTietSuKien(int suKienId) async {
    return Get(
      '/Mobile/TinhNguyenVien/$suKienId/ChiTietSuKien',
          (response) => SuKienChiTietDto.fromJson(response),
    );
  }

  /// Đăng ký sự kiện
  Future<void> dangKySuKien(DangKySuKienRequest request) async {
    return Post(
      '/Mobile/TinhNguyenVien/DangKySuKien',
      request.toJson(),
          (response) => null,
    );
  }

  /// Hủy đăng ký sự kiện
  Future<void> huyDangKySuKien(HuyDangKySuKienRequest request) async {
    return Post(
      '/Mobile/TinhNguyenVien/HuyDangKySuKien',
      request.toJson(),
          (response) => null,
    );
  }

  // ==================== THÔNG BÁO ====================

  /// Lấy danh sách thông báo
  Future<List<ThongBaoDto>> getDanhSachThongBao({
    String? filter,
  }) async {
    final queryParams = <String, dynamic>{};
    if (filter != null && filter != 'TatCa') {
      queryParams['filter'] = filter;
    }

    return Get(
      '/Mobile/TinhNguyenVien/ThongBao',
          (response) => (response as List)
          .map((item) => ThongBaoDto.fromJson(item))
          .toList(),
      queryParams: queryParams,
    );
  }

  /// Lấy số lượng thông báo chưa đọc
  Future<int> getSoLuongChuaDoc() async {
    return Get(
      '/Mobile/TinhNguyenVien/ThongBao/ChuaDoc/SoLuong',
          (response) => response['soLuong'] ?? 0,
    );
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> danhDauDaDoc(int thongBaoId) async {
    return Put(
      '/Mobile/TinhNguyenVien/ThongBao/$thongBaoId/DaDoc',
      {},
          (response) => null,
    );
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> danhDauTatCaDaDoc() async {
    return Put(
      '/Mobile/TinhNguyenVien/ThongBao/DaDoc/TatCa',
      {},
          (response) => null,
    );
  }

  // ============ DANH SÁCH TRẺ EM ============

  // Future<DanhSachTreEmResponse> getDanhSachTreEm() async {
  //   return Get(
  //     '/Mobile/TinhNguyenVien/DanhSachTreEm',
  //         (response) => DanhSachTreEmResponse.fromJson(response),
  //   );
  // }
  Future<DanhSachTreEmResponse> getDanhSachTreEm({
    String? filter,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};

    if (filter != null && filter != 'TatCa') {
      queryParams['filter'] = filter;
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    return Get(
      '/Mobile/TinhNguyenVien/DanhSachTreEm',
          (response) => DanhSachTreEmResponse.fromJson(response),
      queryParams: queryParams,
    );
  }
// ============================================================================
// CHI TIẾT TRẺ EM PHÂN PHÁT QUÀ
// ============================================================================
  Future<ChiTietTreEmPhanPhatQua> getChiTietTreEmPhanPhatQua(int phanPhatId) async {
    return Get(
      '/Mobile/TinhNguyenVien/PhanPhatQua/$phanPhatId',
          (response) => ChiTietTreEmPhanPhatQua.fromJson(response),
    );
  }

// ============================================================================
// CẬP NHẬT PHÂN PHÁT QUÀ
// ============================================================================
  Future<Map<String, dynamic>> capNhatPhanPhatQua(
      CapNhatPhanPhatQuaRequest request) async {
    return Put(
      '/Mobile/TinhNguyenVien/CapNhatPhanPhatQua',
      request.toJson(),
          (response) => response,
    );
  }
  // ============ CHI TIẾT TRẺ CẦN VẬN ĐỘNG ============

  Future<ChiTietTreEmVanDong> getChiTietTreEmVanDong(int treEmId) async {
    return Get(
      '/Mobile/TinhNguyenVien/VanDongTreEm/$treEmId',
          (response) => ChiTietTreEmVanDong.fromJson(response),
    );
  }

  // ============ CHI TIẾT TRẺ HỖ TRỢ PHÚC LỢI ============

  Future<ChiTietTreEmHoTro> getChiTietTreEmHoTro(int hoTroId) async {
    return Get(
      '/Mobile/TinhNguyenVien/HoTroTreEm/$hoTroId',
          (response) => ChiTietTreEmHoTro.fromJson(response),
    );
  }

  // ============ CẬP NHẬT VẬN ĐỘNG ============

  Future<Map<String, dynamic>> capNhatVanDong({
    required int treEmId,
    required int hoanCanhId,
    required String tinhTrangCapNhat,
    required int soLan,
    String? ghiChuChiTiet,
    File? anhMinhChung,
  }) async {
    // Tạo request data
    final data = {
      'treEmID': treEmId,
      'hoanCanhID': hoanCanhId,
      'tinhTrangCapNhat': tinhTrangCapNhat,
      'soLan': soLan,
      'ghiChuChiTiet': ghiChuChiTiet ?? '',
    };

    if (anhMinhChung != null) {
      // Upload với file
      return UploadFile(
        '/Mobile/TinhNguyenVien/CapNhatVanDong',
        anhMinhChung,
            (response) => response,
      );
    } else {
      // Post thông thường (không có ảnh)
      return Post(
        '/Mobile/TinhNguyenVien/CapNhatVanDong',
        data,
            (response) => response,
      );
    }
  }

  // ============ CẬP NHẬT HỖ TRỢ PHÚC LỢI ============

  Future<Map<String, dynamic>> capNhatHoTro({
    required int hoTroId,
    required String trangThaiPhat,
    DateTime? ngayHenLai,
    String? ghiChuTNV,
    required File anhMinhChung, // Bắt buộc
  }) async {
    return UploadFile(
      '/Mobile/TinhNguyenVien/CapNhatHoTro',
      anhMinhChung,
          (response) => response,
    );
  }
}

// Extension cho ApiService để hỗ trợ multipart/form-data
extension ApiServiceMultipart on ApiService {
  Future<T> uploadMultipart<T>(
      String endpoint,
      Map<String, dynamic> fields,
      File file,
      T Function(Map<String, dynamic>) parser,
      ) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}$endpoint');
      print('🌐 POST Multipart Request: $uri');

      final httpClient = ApiService.getHttpClient();
      final request = await httpClient.postUrl(uri);

      // Set headers
      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      // Create multipart boundary
      final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');

      // Build multipart body
      final body = StringBuffer();

      // Add fields
      fields.forEach((key, value) {
        body.write('--$boundary\r\n');
        body.write('Content-Disposition: form-data; name="$key"\r\n\r\n');
        body.write('$value\r\n');
      });

      // Add file
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();

      body.write('--$boundary\r\n');
      body.write('Content-Disposition: form-data; name="file"; filename="$fileName"\r\n');
      body.write('Content-Type: image/jpeg\r\n\r\n');

      // Write body
      request.write(body.toString());
      request.add(fileBytes);
      request.write('\r\n--$boundary--\r\n');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('POST Multipart Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return parser(jsonDecode(responseBody));
      } else if (response.statusCode == 401) {
        await clearAuthToken();
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        print('POST Multipart Response Body: $responseBody');
        throw Exception('Lỗi ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('API POST Multipart Error: $e');
      rethrow;
    }
  }

  // TAB TÀI KHOẢN
  // ============ THÔNG TIN TÀI KHOẢN ============
  Future<TinhNguyenVienProfile> getProfile() async {
    return Get(
      '/Mobile/TinhNguyenVien/Profile',
          (response) => TinhNguyenVienProfile.fromJson(response),
    );
  }
  // ==========================================================================
// LẤY DANH SÁCH KHU PHỐ
// ==========================================================================
  Future<List<KhuPhoDto>> getDanhSachKhuPho() async {
    return Get(
      '/Mobile/TinhNguyenVien/DanhSachKhuPho',
          (response) => (response as List)
          .map((item) => KhuPhoDto.fromJson(item))
          .toList(),
    );
  }

// ==========================================================================
// CẬP NHẬT THÔNG TIN TÀI KHOẢN
// ==========================================================================
  Future<TinhNguyenVienProfile> capNhatThongTinTaiKhoan(
      UpdateProfileRequest request) async {
    return Put(
      '/Mobile/TinhNguyenVien/Profile',
      request.toJson(),
          (response) => TinhNguyenVienProfile.fromJson(response['profile']),
    );
  }

  // ============ LỊCH SỬ HOẠT ĐỘNG ============
  Future<LichSuHoatDong> getLichSuHoatDong({
    String? khuPho,
    int page = 1,
    int pageSize = 10,
  }) async {
    var endpoint = '/Mobile/TinhNguyenVien/LichSuHoatDong?page=$page&pageSize=$pageSize';
    if (khuPho != null && khuPho.isNotEmpty) {
      endpoint += '&khuPho=$khuPho';
    }

    return Get(
      endpoint,
          (response) => LichSuHoatDong.fromJson(response),
    );
  }

  // ==========================================================================
  // ĐỔI MẬT KHẨU
  // ==========================================================================
  Future<void> doiMatKhau(String matKhauCu, String matKhauMoi) async {
    return Post('/mobile/Auth/DoiMatKhau',
        {'matKhauCu': matKhauCu, 'matKhauMoi': matKhauMoi},
            (response) {});
  }

  Future<void> dangXuat() async {
    return Post('/mobile/Auth/DangXuat', {}, (response) {});
  }
  // ==========================================================================
  // CẬP NHẬT AVATAR
  // ==========================================================================
  Future<String> capNhatAvatar(File file) async {
    return UploadFile(
      '/Mobile/TinhNguyenVien/CapNhatAvatar',
      file,
          (response) => response['anh'] as String,
    );
  }
}