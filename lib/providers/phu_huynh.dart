import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dashboard_phu_huynh.dart';
import '../models/tab_con_toi.dart';
import '../models/tab_su_kien_ph.dart';
import '../models/tab_tai_khoan_ph.dart';
import '../models/tab_thong_bao_ph.dart';
import '../services/phu_huynh.dart';

class PhuHuynhProvider extends ChangeNotifier {
  final ParentService _service = ParentService();

  // --- STATE ---
  DashboardPhuHuynh? _dashboard;
  List<TreEmBasicInfo> _danhSachCon = [];
  Map<int, List<PhieuHocTapInfo>> _phieuHocTapMap = {};
  Map<int, TabQuaDaNhanResponse> _quaDaNhanMap = {};

  List<DanhSachSuKien> _danhSachSuKien = [];
  ChiTietSuKienResponse? _chiTietSuKien;
  String _currentFilter = 'sap-dien-ra';
  int _currentPage = 1;
  bool _hasMoreSuKien = true;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  TabThongBaoResponse? _thongBaoData;
  // ThongTinPhuHuynhResponse? _thongTinPhuHuynh;
  ThongTinTaiKhoanResponse? _thongTinTaiKhoan;
  ThongTinTreEmChiTietResponse? _thongTinTreEm;
  List<PhuHuynhVoiMoiQuanHe> _danhSachPhuHuynh = [];
  PhuHuynhVoiMoiQuanHe? _chiTietPhuHuynh;

  // --- GETTERS ---
  DashboardPhuHuynh? get dashboard => _dashboard;
  List<TreEmBasicInfo> get danhSachCon => _danhSachCon;
  List<DanhSachSuKien> get danhSachSuKien => _danhSachSuKien;
  ChiTietSuKienResponse? get chiTietSuKien => _chiTietSuKien;
  String get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreSuKien => _hasMoreSuKien;
  String? get errorMessage => _errorMessage;
  TabThongBaoResponse? get thongBaoData => _thongBaoData;
  // ThongTinPhuHuynhResponse? get thongTinPhuHuynh => _thongTinPhuHuynh;
  ThongTinTaiKhoanResponse? get thongTinTaiKhoan => _thongTinTaiKhoan;
  ThongTinTreEmChiTietResponse? get thongTinTreEm => _thongTinTreEm;

  List<PhieuHocTapInfo> getPhieuHocTap(int treEmId) => _phieuHocTapMap[treEmId] ?? [];

  TabQuaDaNhanResponse? getQuaDaNhan(int treEmId) => _quaDaNhanMap[treEmId];

  List<PhuHuynhVoiMoiQuanHe> get danhSachPhuHuynh => _danhSachPhuHuynh;
  PhuHuynhVoiMoiQuanHe? get chiTietPhuHuynh => _chiTietPhuHuynh;


  // --- DASHBOARD ---
  Future<void> loadDashboard({int? treEmId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _dashboard = await _service.getDashboard(treEmId: treEmId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- DANH SÁCH CON ---
  Future<void> loadDanhSachCon() async {
    try {
      final response = await _service.getDanhSachCon();
      _danhSachCon = response.danhSachCon;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // --- HỌC TẬP ---
  Future<void> loadPhieuHocTap(int treEmId) async {
    try {
      final response = await _service.getTabHocTap(treEmId);
      _phieuHocTapMap[treEmId] = response.danhSachPhieuHocTap;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadQuaDaNhan(int treEmId, {String filter = 'all'}) async {
    try {
      final response = await _service.getQuaDaNhan(treEmId, filter: filter);
      _quaDaNhanMap[treEmId] = response;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // --- SỰ KIỆN ---

  /// Load danh sách sự kiện với filter
  Future<void> loadDanhSachSuKien(String filter, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreSuKien = true;
      _danhSachSuKien.clear();
    }

    if (!_hasMoreSuKien && !refresh) return;

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _errorMessage = null;
    _currentFilter = filter;
    notifyListeners();

    try {
      final list = await _service.getDanhSachSuKien(filter);

      if (refresh) {
        _danhSachSuKien = list;
      } else {
        _danhSachSuKien.addAll(list);
      }

      // Pagination logic (giả sử API trả về tối đa 20 items)
      if (list.length < 20) {
        _hasMoreSuKien = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more sự kiện (for infinite scroll)
  Future<void> loadMoreSuKien() async {
    if (!_isLoadingMore && _hasMoreSuKien) {
      await loadDanhSachSuKien(_currentFilter);
    }
  }

  /// Load chi tiết sự kiện
  Future<void> loadChiTietSuKien(int suKienId) async {
    _isLoading = true;
    _errorMessage = null;
    _chiTietSuKien = null;
    notifyListeners();

    try {
      _chiTietSuKien = await _service.getChiTietSuKien(suKienId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng ký sự kiện
  Future<DangKySuKienResponse?> dangKySuKien(int suKienId) async {
    try {
      final response = await _service.dangKySuKien(suKienId);

      // Update local state
      final index = _danhSachSuKien.indexWhere((sk) => sk.suKienId == suKienId);
      if (index != -1) {
        _danhSachSuKien[index] = DanhSachSuKien(
          suKienId: _danhSachSuKien[index].suKienId,
          tenSuKien: _danhSachSuKien[index].tenSuKien,
          ngayBatDau: _danhSachSuKien[index].ngayBatDau,
          ngayKetThuc: _danhSachSuKien[index].ngayKetThuc,
          diaDiem: _danhSachSuKien[index].diaDiem,
          tenKhuPho: _danhSachSuKien[index].tenKhuPho,
          daDangKy: true,
          trangThaiDangKy: response.trangThai,
        );
      }

      // Update chi tiết if loaded
      if (_chiTietSuKien?.suKienId == suKienId) {
        _chiTietSuKien = ChiTietSuKienResponse(
          suKienId: _chiTietSuKien!.suKienId,
          tenSuKien: _chiTietSuKien!.tenSuKien,
          moTa: _chiTietSuKien!.moTa,
          diaDiem: _chiTietSuKien!.diaDiem,
          ngayBatDau: _chiTietSuKien!.ngayBatDau,
          ngayKetThuc: _chiTietSuKien!.ngayKetThuc,
          soLuongTinhNguyenVien: _chiTietSuKien!.soLuongTinhNguyenVien,
          soLuongTreEm: _chiTietSuKien!.soLuongTreEm,
          nguoiChiuTrachNhiem: _chiTietSuKien!.nguoiChiuTrachNhiem,
          tenKhuPho: _chiTietSuKien!.tenKhuPho,
          diaChiKhuPho: _chiTietSuKien!.diaChiKhuPho,
          daDangKy: true,
          trangThaiDangKy: response.trangThai,
          danhSachChuongTrinh: _chiTietSuKien!.danhSachChuongTrinh,
        );
      }

      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Hủy đăng ký sự kiện
  Future<bool> huyDangKySuKien(int suKienId) async {
    try {
      final success = await _service.huyDangKySuKien(suKienId);

      if (success) {
        // Update local state
        final index = _danhSachSuKien.indexWhere((sk) => sk.suKienId == suKienId);
        if (index != -1) {
          _danhSachSuKien[index] = DanhSachSuKien(
            suKienId: _danhSachSuKien[index].suKienId,
            tenSuKien: _danhSachSuKien[index].tenSuKien,
            ngayBatDau: _danhSachSuKien[index].ngayBatDau,
            ngayKetThuc: _danhSachSuKien[index].ngayKetThuc,
            diaDiem: _danhSachSuKien[index].diaDiem,
            tenKhuPho: _danhSachSuKien[index].tenKhuPho,
            daDangKy: false,
            trangThaiDangKy: '',
          );
        }

        // Update chi tiết if loaded
        if (_chiTietSuKien?.suKienId == suKienId) {
          _chiTietSuKien = ChiTietSuKienResponse(
            suKienId: _chiTietSuKien!.suKienId,
            tenSuKien: _chiTietSuKien!.tenSuKien,
            moTa: _chiTietSuKien!.moTa,
            diaDiem: _chiTietSuKien!.diaDiem,
            ngayBatDau: _chiTietSuKien!.ngayBatDau,
            ngayKetThuc: _chiTietSuKien!.ngayKetThuc,
            soLuongTinhNguyenVien: _chiTietSuKien!.soLuongTinhNguyenVien,
            soLuongTreEm: _chiTietSuKien!.soLuongTreEm,
            nguoiChiuTrachNhiem: _chiTietSuKien!.nguoiChiuTrachNhiem,
            tenKhuPho: _chiTietSuKien!.tenKhuPho,
            diaChiKhuPho: _chiTietSuKien!.diaChiKhuPho,
            daDangKy: false,
            trangThaiDangKy: '',
            danhSachChuongTrinh: _chiTietSuKien!.danhSachChuongTrinh,
          );
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- THÔNG BÁO ---
  Future<void> loadDanhSachThongBao({String filter = 'all'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _thongBaoData = await _service.getDanhSachThongBao(filter: filter);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> danhDauDaDoc(int thongBaoID) async {
    try {
      await _service.danhDauDaDoc(thongBaoID);

      // Update local state
      if (_thongBaoData != null) {
        final index = _thongBaoData!.danhSachThongBao
            .indexWhere((tb) => tb.thongBaoID == thongBaoID);
        if (index != -1) {
          final updatedList = List<ThongBaoInfo>.from(_thongBaoData!.danhSachThongBao);
          updatedList[index] = ThongBaoInfo(
            thongBaoID: updatedList[index].thongBaoID,
            noiDung: updatedList[index].noiDung,
            ngayThongBao: updatedList[index].ngayThongBao,
            daDoc: true,
            suKienID: updatedList[index].suKienID,
            tenSuKien: updatedList[index].tenSuKien,
          );
          _thongBaoData = TabThongBaoResponse(
            soLuongChuaDoc: _thongBaoData!.soLuongChuaDoc - 1,
            danhSachThongBao: updatedList,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
// --- THÔNG TIN TÀI KHOẢN ---
  Future<void> loadThongTinTaiKhoan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _thongTinTaiKhoan = await _service.getThongTinTaiKhoan();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadAnhTaiKhoan(File file) async {
    try {
      final filePath = await _service.uploadAnhTaiKhoan(file);
      if (_thongTinTaiKhoan != null) {
        _thongTinTaiKhoan = ThongTinTaiKhoanResponse(
          userID: _thongTinTaiKhoan!.userID,
          hoTen: _thongTinTaiKhoan!.hoTen,
          email: _thongTinTaiKhoan!.email,
          sdt: _thongTinTaiKhoan!.sdt,
          anh: filePath,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
  // Load danh sách phụ huynh
  Future<void> loadDanhSachPhuHuynh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getDanhSachPhuHuynh();
      _danhSachPhuHuynh = response.danhSachPhuHuynh;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load chi tiết phụ huynh
  Future<void> loadChiTietPhuHuynh(int phuHuynhId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _chiTietPhuHuynh = await _service.getChiTietPhuHuynh(phuHuynhId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật phụ huynh
  Future<void> capNhatPhuHuynh(Map<String, dynamic> data) async {
    await _service.capNhatPhuHuynh(data);
    await loadDanhSachPhuHuynh(); // Reload list
    if (data['phuHuynhID'] != null) {
      await loadChiTietPhuHuynh(data['phuHuynhID']); // Reload detail
    }
  }

  // Upload ảnh phụ huynh cụ thể
  Future<void> uploadAnhPhuHuynhCuThe(int phuHuynhId, File file) async {
    await _service.uploadAnhPhuHuynhCuThe(phuHuynhId, file);
    await loadDanhSachPhuHuynh(); // Reload list
    await loadChiTietPhuHuynh(phuHuynhId); // Reload detail
  }
  // Future<void> loadThongTinPhuHuynh() async {
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     _thongTinPhuHuynh = await _service.getThongTinPhuHuynh();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> capNhatThongTinPhuHuynh(Map<String, dynamic> data) async {
  //   await _service.capNhatThongTinPhuHuynh(data);
  //   await loadThongTinPhuHuynh(); // Reload data
  // }
  //
  // Future<void> uploadAnhPhuHuynh(File file) async {
  //   final filePath = await _service.uploadAnhPhuHuynh(file);
  //   if (_thongTinPhuHuynh != null) {
  //     _thongTinPhuHuynh = ThongTinPhuHuynhResponse(
  //       phuHuynhID: _thongTinPhuHuynh!.phuHuynhID,
  //       hoTen: _thongTinPhuHuynh!.hoTen,
  //       sdt: _thongTinPhuHuynh!.sdt,
  //       email: _thongTinPhuHuynh!.email,
  //       diaChi: _thongTinPhuHuynh!.diaChi,
  //       ngheNghiep: _thongTinPhuHuynh!.ngheNghiep,
  //       ngaySinh: _thongTinPhuHuynh!.ngaySinh,
  //       tonGiao: _thongTinPhuHuynh!.tonGiao,
  //       danToc: _thongTinPhuHuynh!.danToc,
  //       quocTich: _thongTinPhuHuynh!.quocTich,
  //       anh: filePath,
  //     );
  //     notifyListeners();
  //   }
  // }
  Future<void> loadThongTinTreEm(int treEmId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _thongTinTreEm = await _service.getThongTinTreEm(treEmId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> capNhatThongTinTreEm(Map<String, dynamic> data) async {
    await _service.capNhatThongTinTreEm(data);
    await loadThongTinTreEm(data['treEmID']); // Reload data
  }

  Future<void> uploadAnhTreEm(int treEmId, File file) async {
    await _service.uploadAnhTreEm(treEmId, file);
    await loadThongTinTreEm(treEmId); // Reload data
  }

  // --- MẬT KHẨU ---
  Future<void> doiMatKhau(String matKhauCu, String matKhauMoi) async {
    await _service.doiMatKhau(matKhauCu, matKhauMoi);
  }

  // --- ĐĂNG XUẤT ---
  Future<void> dangXuat() async {
    await _service.dangXuat();
  }

  // --- CLEAR ALL ---
  void clearAll() {
    _dashboard = null;
    _danhSachCon = [];
    _phieuHocTapMap = {};
    _quaDaNhanMap = {};
    _thongBaoData = null;
    // _thongTinPhuHuynh = null;
    _thongTinTaiKhoan = null;
    _thongTinTreEm = null;
    _danhSachPhuHuynh = [];
    _chiTietPhuHuynh = null;
    _errorMessage = null;
    notifyListeners();
  }

  // --- CLEAR ERROR ---
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
