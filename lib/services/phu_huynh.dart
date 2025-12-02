import 'dart:io';
import '../models/dashboard_phu_huynh.dart';
import '../models/tab_con_toi.dart';
import '../models/tab_su_kien_ph.dart';
import '../models/tab_tai_khoan_ph.dart';
import '../models/tab_thong_bao_ph.dart';
import 'api.dart';

class ParentService extends ApiService {
  // Dashboard
  Future<DashboardPhuHuynh> getDashboard({int? treEmId}) async {
    final queryParams = treEmId != null ? '?treEmId=$treEmId' : '';
    return Get('/Mobile/PhuHuynh/Home$queryParams',
      (response) => DashboardPhuHuynh.fromJson(response),
    );
  }

  // Tab Con tôi
  Future<DanhSachConResponse> getDanhSachCon() async {
    return Get('/Mobile/PhuHuynh/DanhSachCon',
      (response) => DanhSachConResponse.fromJson(response),
    );
  }

  Future<TabHocTapResponse> getTabHocTap(int treEmId) async {
    return Get('/Mobile/PhuHuynh/HocTap/$treEmId',
      (response) => TabHocTapResponse.fromJson(response),
    );
  }

  Future<TabQuaDaNhanResponse> getQuaDaNhan(int treEmId, {String filter = 'all'}) async {
    return Get('/Mobile/PhuHuynh/QuaDaNhan/$treEmId?filter=$filter',
          (response) => TabQuaDaNhanResponse.fromJson(response),
    );
  }

  // Future<TabHoTroResponse> getTabHoTro(int treEmId) async {
  //   return Get('/Mobile/PhuHuynh/HoTro/$treEmId',
  //       (response) => TabHoTroResponse.fromJson(response)
  //   );
  // }

  //Tab sự kiện
  // Lấy danh sách sự kiện với filter
  Future<List<DanhSachSuKien>> getDanhSachSuKien(String filter) async {
    return Get('/Mobile/PhuHuynh/DanhSachSuKien?filter=$filter',
          (response) {
        var list = response['danhSachSuKien'] as List;
        return list.map((item) => DanhSachSuKien.fromJson(item)).toList();
      },
    );
  }

  // Lấy chi tiết sự kiện
  Future<ChiTietSuKienResponse> getChiTietSuKien(int suKienId) async {
    return Get('/Mobile/PhuHuynh/ChiTietSuKien/$suKienId',
        (response) => ChiTietSuKienResponse.fromJson(response),
    );
  }

  // Đăng ký sự kiện
  Future<DangKySuKienResponse> dangKySuKien(int suKienId) async {
    return Post('/Mobile/PhuHuynh/DangKySuKien', {'suKienId': suKienId},
        (response) => DangKySuKienResponse.fromJson(response),
    );
  }

  // Hủy đăng ký sự kiện
  Future<bool> huyDangKySuKien(int suKienId) async {
    return Delete('/Mobile/PhuHuynh/HuyDangKySuKien/$suKienId',
        (response) => response['success'] ?? false,
    );
  }

  // Tab Thông báo
  Future<TabThongBaoResponse> getDanhSachThongBao({String filter = 'all'}) async {
    return Get('/Mobile/PhuHuynh/ThongBao?filter=$filter',
        (response) => TabThongBaoResponse.fromJson(response),
    );
  }

  Future<void> danhDauDaDoc(int thongBaoID) async {
    return Post('/Mobile/PhuHuynh/ThongBao/DanhDauDaDoc',
        {'thongBaoID': thongBaoID},
            (response) {});
  }

  // Tab Tài khoản - Thông tin phụ huynh
  Future<ThongTinTaiKhoanResponse> getThongTinTaiKhoan() async {
    return Get('/Mobile/PhuHuynh/ThongTinTaiKhoan',
          (response) => ThongTinTaiKhoanResponse.fromJson(response),
    );
  }

  Future<String> uploadAnhTaiKhoan(File file) async {
    return UploadFile('/Mobile/PhuHuynh/UploadAnhTaiKhoan', file,
          (response) => response['filePath'],
    );
  }
  //Danh sách phụ huynh
  Future<DanhSachPhuHuynhResponse> getDanhSachPhuHuynh() async {
    return Get('/Mobile/PhuHuynh/DanhSachPhuHuynh',
            (response) => DanhSachPhuHuynhResponse.fromJson(response));
  }

  // Chi tiết phụ huynh
  Future<PhuHuynhVoiMoiQuanHe> getChiTietPhuHuynh(int phuHuynhId) async {
    return Get('/Mobile/PhuHuynh/ChiTietPhuHuynh/$phuHuynhId',
            (response) => PhuHuynhVoiMoiQuanHe.fromJson(response));
  }

  // Future<ThongTinPhuHuynhResponse> getThongTinPhuHuynh() async {
  //   return Get('/Mobile/PhuHuynh/ThongTin',
  //         (response) => ThongTinPhuHuynhResponse.fromJson(response),
  //   );
  // }

  // Future<void> capNhatThongTinPhuHuynh(Map<String, dynamic> data) async {
  //   return Put('/Mobile/PhuHuynh/CapNhatThongTin', data, (response) {});
  // }
  // Cập nhật phụ huynh
  Future<void> capNhatPhuHuynh(Map<String, dynamic> data) async {
    if (data['ngaySinh'] != null && data['ngaySinh'] is String) {
      try {
        String dateString = data['ngaySinh'];
        if (dateString.contains('-')) {
          DateTime date = DateTime.parse(dateString);
          // data['ngaySinh'] ="date.day.toString().padLeft(2,′0′)/{date.day.toString().padLeft(2, '0')}/date.day.toString().padLeft(2,′0′)/{date.month.toString().padLeft(2, '0')}/${date.year}";
          data['ngaySinh'] ='${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
      } catch (e) {
        print('Error formatting ngaySinh: $e');
      }
    }
    return Put('/Mobile/PhuHuynh/CapNhatPhuHuynh', data, (response) {});
  }

  // Future<String> uploadAnhPhuHuynh(File file) async {
  //   return UploadFile('/Mobile/PhuHuynh/UploadAnh', file,
  //     (response) => response['filePath'],
  //   );
  // }
  // Upload ảnh phụ huynh cụ thể
  // Future<String> uploadAnhPhuHuynhCuThe(int phuHuynhId, File file) async {
  //   return UploadFile('/Mobile/PhuHuynh/UploadAnhPhuHuynh/$phuHuynhId', file,
  //           (response) => response['filePath']);
  // }
  // Upload ảnh phụ huynh cụ thể
  Future<String> uploadAnhPhuHuynhCuThe(int phuHuynhId, File file) async {
    print('=== BẮT ĐẦU UPLOAD ẢNH PHỤ HUYNH ===');
    print('Phụ huynh ID: $phuHuynhId');
    print('File path: ${file.path}');

    // Kiểm tra file
    if (!await file.exists()) {
      throw Exception('File không tồn tại');
    }

    final fileSize = await file.length();
    print('File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

    if (fileSize > 10 * 1024 * 1024) {
      throw Exception('File quá lớn (tối đa 10MB)');
    }

    return UploadFile(
        '/Mobile/PhuHuynh/UploadAnhPhuHuynh/$phuHuynhId',
        file,
            (response) {
          print('Response data: $response');

          if (response.containsKey('filePath')) {
            return response['filePath'] as String;
          } else if (response.containsKey('path')) {
            return response['path'] as String;
          } else if (response.containsKey('url')) {
            return response['url'] as String;
          } else if (response.containsKey('data') && response['data'] is Map) {
            final data = response['data'] as Map<String, dynamic>;
            if (data.containsKey('filePath')) {
              return data['filePath'] as String;
            }
          }

          throw Exception('Response không chứa đường dẫn file: $response');
        }
    );
  }


  // Tab Tài khoản - Thông tin trẻ em
  Future<ThongTinTreEmChiTietResponse> getThongTinTreEm(int treEmId) async {
    return Get('/Mobile/PhuHuynh/ThongTinTreEm/$treEmId',
        (response) => ThongTinTreEmChiTietResponse.fromJson(response),
    );
  }

  Future<void> capNhatThongTinTreEm(Map<String, dynamic> data) async {
    if (data['NgaySinh'] != null && data['NgaySinh'] is String) {
      try {
        String dateString = data['NgaySinh'];
        if (dateString.contains('-')) {
          DateTime date = DateTime.parse(dateString);
          data['NgaySinh'] = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
      } catch (e) {
        print('Error formatting NgaySinh: $e');
      }
    }
    return Put('/Mobile/PhuHuynh/CapNhatTreEm', data, (response) {});
  }

  Future<String> uploadAnhTreEm(int treEmId, File file) async {
    return UploadFile('/Mobile/PhuHuynh/UploadAnhTreEm/$treEmId', file,
        (response) => response['filePath'],
    );
  }

  // Đổi mật khẩu & Đăng xuất
  Future<void> doiMatKhau(String matKhauCu, String matKhauMoi) async {
    return Post('/mobile/Auth/DoiMatKhau',
      {'matKhauCu': matKhauCu, 'matKhauMoi': matKhauMoi},
        (response) {});
  }

  Future<void> dangXuat() async {
    return Post('/mobile/Auth/DangXuat', {}, (response) {});
  }
}