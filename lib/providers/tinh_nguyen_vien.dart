import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_tnv.dart';
import '../models/tab_su_kien_tnv.dart';
import '../models/tab_tai_khoan_tnv.dart';
import '../models/tab_thong_bao_tnv.dart';
import '../models/tab_tre_em_tnv.dart';
import '../services/tinh_nguyen_vien.dart';


class VolunteerProvider extends ChangeNotifier {
  final VolunteerService _service = VolunteerService();
  // States
  bool _isLoading = false;
  String? _errorMessage;
  TinhNguyenVienHomeModel? _homeData;
  LichTrongModel? _lichTrong;

  bool _isLoadingSuKien = false;
  String? _errorMessageSuKien;
  List<SuKienListDto> _danhSachSuKien = [];
  SuKienChiTietDto? _suKienChiTiet;
  String _suKienFilter = 'TatCa';
  String _suKienSearchQuery = '';

  bool _isLoadingThongBao = false;
  String? _errorMessageThongBao;
  List<ThongBaoDto> _danhSachThongBao = [];
  String _thongBaoFilter = 'TatCa';
  int _soLuongChuaDoc = 0;

  List<TreEmCanVanDong> _treCanVanDong = [];
  List<TreEmPhanPhatQua> _trePhanPhatQua = [];
  ChiTietTreEmVanDong? _chiTietTreVanDong;
  ChiTietTreEmPhanPhatQua? _chiTietTrePhanPhatQua;

  String _filterPhanPhatQua = 'TatCa';
  String _searchQueryPhanPhatQua = '';

  List<KhuPhoDto> _danhSachKhuPho = [];
  bool _isLoadingKhuPho = false;
  TinhNguyenVienProfile? _profile;
  LichSuHoatDong? _lichSuHoatDong;
  int _currentPage = 1;
  final int _pageSize = 10;
  String? _filterKhuPho;
  bool _hasMoreData = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TinhNguyenVienHomeModel? get homeData => _homeData;
  ThongTinTaiKhoanModel? get thongTinTaiKhoan => _homeData?.thongTinTaiKhoan;
  List<SuKienPhanCongModel> get suKienPhanCong => _homeData?.suKienPhanCong ?? [];
  ThongKeHoatDongModel? get thongKe => _homeData?.thongKe;
  LichTrongModel? get lichTrong => _lichTrong ?? _homeData?.lichTrong;

  bool get isLoadingSuKien => _isLoadingSuKien;
  String? get errorMessageSuKien => _errorMessageSuKien;
  List<SuKienListDto> get danhSachSuKien => _danhSachSuKien;
  SuKienChiTietDto? get suKienChiTiet => _suKienChiTiet;
  String get suKienFilter => _suKienFilter;
  String get suKienSearchQuery => _suKienSearchQuery;

  bool get isLoadingThongBao => _isLoadingThongBao;
  String? get errorMessageThongBao => _errorMessageThongBao;
  List<ThongBaoDto> get danhSachThongBao => _danhSachThongBao;
  String get thongBaoFilter => _thongBaoFilter;
  int get soLuongChuaDoc => _soLuongChuaDoc;

  List<TreEmCanVanDong> get treCanVanDong => _treCanVanDong;
  List<TreEmPhanPhatQua> get trePhanPhatQua => _trePhanPhatQua;
  ChiTietTreEmVanDong? get chiTietTreVanDong => _chiTietTreVanDong;
  ChiTietTreEmPhanPhatQua? get chiTietTrePhanPhatQua => _chiTietTrePhanPhatQua;

  String get filterPhanPhatQua => _filterPhanPhatQua;
  String get searchQueryPhanPhatQua => _searchQueryPhanPhatQua;

  List<KhuPhoDto> get danhSachKhuPho => _danhSachKhuPho;
  bool get isLoadingKhuPho => _isLoadingKhuPho;
  TinhNguyenVienProfile? get profile => _profile;
  LichSuHoatDong? get lichSuHoatDong => _lichSuHoatDong;
  String? get filterKhuPho => _filterKhuPho;
  bool get hasMoreData => _hasMoreData;

  // ==================== HOMEE METHODS ====================
  // Load trang chủ
  Future<void> loadHome() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _homeData = await _service.getHome();
      _lichTrong = _homeData?.lichTrong;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load lịch trống
  Future<void> loadLichTrong() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _lichTrong = await _service.getLichTrong();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cập nhật lịch trống
  Future<bool> updateLichTrong(LichTrongModel lichTrong) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _service.updateLichTrong(lichTrong);

      if (success) {
        _lichTrong = lichTrong;
        // Cập nhật isEmpty flag
        _lichTrong = LichTrongModel(
          lichTrongId: lichTrong.lichTrongId,
          isEmpty: !lichTrong.chiTietLichTrong.any((ct) => ct.isAvailable),
          chiTietLichTrong: lichTrong.chiTietLichTrong,
        );
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== SỰ KIỆN METHODS ====================

  /// Lấy danh sách sự kiện
  Future<void> loadDanhSachSuKien({String? filter, String? search}) async {
    _isLoadingSuKien = true;
    _errorMessageSuKien = null;
    notifyListeners();

    if (filter != null) _suKienFilter = filter;
    if (search != null) _suKienSearchQuery = search;

    try {
      _danhSachSuKien = await _service.getDanhSachSuKien(
        filter: _suKienFilter,
        search: _suKienSearchQuery.isEmpty ? null : _suKienSearchQuery,
      );
      _errorMessageSuKien = null;
    } catch (e) {
      _errorMessageSuKien = e.toString();
      if (kDebugMode) print('Error loading danh sách sự kiện: $e');
    } finally {
      _isLoadingSuKien = false;
      notifyListeners();
    }
  }

  /// Lấy chi tiết sự kiện
  Future<void> loadChiTietSuKien(int suKienId) async {
    _isLoadingSuKien = true;
    _errorMessageSuKien = null;
    _suKienChiTiet = null;
    notifyListeners();

    try {
      _suKienChiTiet = await _service.getChiTietSuKien(suKienId);
      _errorMessageSuKien = null;
    } catch (e) {
      _errorMessageSuKien = e.toString();
      if (kDebugMode) print('Error loading chi tiết sự kiện: $e');
    } finally {
      _isLoadingSuKien = false;
      notifyListeners();
    }
  }

  /// Đăng ký sự kiện
  Future<bool> dangKySuKien(int suKienId) async {
    try {
      final request = DangKySuKienRequest(suKienId: suKienId);
      await _service.dangKySuKien(request);

      // Reload data
      await loadChiTietSuKien(suKienId);
      await loadDanhSachSuKien();

      return true;
    } catch (e) {
      _errorMessageSuKien = e.toString();
      if (kDebugMode) print('Error đăng ký sự kiện: $e');
      notifyListeners();
      return false;
    }
  }

  /// Hủy đăng ký sự kiện
  Future<bool> huyDangKySuKien(int dangKyId, String lyDo, int suKienId) async {
    try {
      final request = HuyDangKySuKienRequest(dangKyId: dangKyId, lyDo: lyDo);
      await _service.huyDangKySuKien(request);

      // Reload data
      await loadChiTietSuKien(suKienId);
      await loadDanhSachSuKien();

      return true;
    } catch (e) {
      _errorMessageSuKien = e.toString();
      if (kDebugMode) print('Error hủy đăng ký sự kiện: $e');
      notifyListeners();
      return false;
    }
  }

  /// Tìm kiếm sự kiện
  void searchSuKien(String query) {
    _suKienSearchQuery = query;
    loadDanhSachSuKien();
  }

  /// Đổi bộ lọc sự kiện
  void changeSuKienFilter(String filter) {
    _suKienFilter = filter;
    loadDanhSachSuKien();
  }

  /// Reset chi tiết sự kiện
  void resetSuKienChiTiet() {
    _suKienChiTiet = null;
    notifyListeners();
  }

  // ==================== THÔNG BÁO METHODS ====================

  /// Lấy danh sách thông báo
  Future<void> loadDanhSachThongBao({String? filter}) async {
    _isLoadingThongBao = true;
    _errorMessageThongBao = null;
    notifyListeners();

    if (filter != null) _thongBaoFilter = filter;

    try {
      _danhSachThongBao = await _service.getDanhSachThongBao(
        filter: _thongBaoFilter,
      );
      await loadSoLuongChuaDoc();
      _errorMessageThongBao = null;
    } catch (e) {
      _errorMessageThongBao = e.toString();
      if (kDebugMode) print('Error loading danh sách thông báo: $e');
    } finally {
      _isLoadingThongBao = false;
      notifyListeners();
    }
  }

  /// Lấy số lượng thông báo chưa đọc
  Future<void> loadSoLuongChuaDoc() async {
    try {
      _soLuongChuaDoc = await _service.getSoLuongChuaDoc();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading số lượng chưa đọc: $e');
    }
  }

  /// Đánh dấu đã đọc
  Future<void> danhDauDaDoc(int thongBaoId) async {
    try {
      await _service.danhDauDaDoc(thongBaoId);

      // Update local state
      final index = _danhSachThongBao.indexWhere((tb) => tb.thongBaoId == thongBaoId);
      if (index != -1) {
        _danhSachThongBao[index] = _danhSachThongBao[index].copyWith(daDoc: true);
      }

      await loadSoLuongChuaDoc();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error đánh dấu đã đọc: $e');
    }
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> danhDauTatCaDaDoc() async {
    try {
      await _service.danhDauTatCaDaDoc();

      // Update local state
      _danhSachThongBao = _danhSachThongBao
          .map((tb) => tb.copyWith(daDoc: true))
          .toList();

      _soLuongChuaDoc = 0;
      notifyListeners();
    } catch (e) {
      _errorMessageThongBao = e.toString();
      if (kDebugMode) print('Error đánh dấu tất cả đã đọc: $e');
      notifyListeners();
    }
  }

  /// Đổi bộ lọc thông báo
  void changeThongBaoFilter(String filter) {
    _thongBaoFilter = filter;
    loadDanhSachThongBao();
  }
  // ==================== TRẺ EM METHODS ====================
  /// Danh sách trẻ em
  Future<void> loadDanhSachTreEm({String? filter, String? search}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (filter != null) _filterPhanPhatQua = filter;
      if (search != null) _searchQueryPhanPhatQua = search;

      final response = await _service.getDanhSachTreEm(
        filter: _filterPhanPhatQua,
        search: _searchQueryPhanPhatQua.isEmpty ? null : _searchQueryPhanPhatQua,
      );

      _treCanVanDong = response.treCanVanDong;
      _trePhanPhatQua = response.trePhanPhatQua;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi tải danh sách trẻ: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) print('Error loading danh sach tre em: $e');
    }
  }

  /// Chi tiết trẻ vận động
  Future<void> loadChiTietTreVanDong(int treEmId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _chiTietTreVanDong = await _service.getChiTietTreEmVanDong(treEmId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi tải chi tiết trẻ: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) print('Error loading chi tiet tre van dong: $e');
    }
  }

  /// Chi tiết trẻ hỗ trợ
  // Future<void> loadChiTietTreHoTro(int hoTroId) async {
  //   try {
  //     _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();
  //
  //     _chiTietTreHoTro = await _service.getChiTietTreEmHoTro(hoTroId);
  //
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _isLoading = false;
  //     _errorMessage = 'Lỗi tải chi tiết hỗ trợ: ${e.toString()}';
  //     notifyListeners();
  //     if (kDebugMode) print('Error loading chi tiet tre ho tro: $e');
  //   }
  // }
  ///LOAD CHI TIẾT TRẺ PHÂN PHÁT QUÀ
  Future<void> loadChiTietTrePhanPhatQua(int phanPhatId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _chiTietTrePhanPhatQua = await _service.getChiTietTreEmPhanPhatQua(phanPhatId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi tải chi tiết phân phát quà: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) print('Error loading chi tiet tre phan phat qua: $e');
    }
  }

  /// Cập nhật vận động
  Future<bool> capNhatVanDong({
    required int treEmId,
    required int hoanCanhId,
    required String tinhTrangCapNhat,
    required int soLan,
    String? ghiChuChiTiet,
    File? anhMinhChung,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _service.capNhatVanDong(
        treEmId: treEmId,
        hoanCanhId: hoanCanhId,
        tinhTrangCapNhat: tinhTrangCapNhat,
        soLan: soLan,
        ghiChuChiTiet: ghiChuChiTiet,
        anhMinhChung: anhMinhChung,
      );

      _isLoading = false;

      if (result['success'] == true) {
        // Reload danh sách
        await loadDanhSachTreEm();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Cập nhật thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi cập nhật vận động: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) print('Error cap nhat van dong: $e');
      return false;
    }
  }

  /// Cập nhật hỗ trợ phúc lợi
  Future<bool> capNhatHoTro({
    required int hoTroId,
    required String trangThaiPhat,
    DateTime? ngayHenLai,
    String? ghiChuTNV,
    required File anhMinhChung,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _service.capNhatHoTro(
        hoTroId: hoTroId,
        trangThaiPhat: trangThaiPhat,
        ngayHenLai: ngayHenLai,
        ghiChuTNV: ghiChuTNV,
        anhMinhChung: anhMinhChung,
      );

      _isLoading = false;

      if (result['success'] == true) {
        // Reload danh sách
        await loadDanhSachTreEm();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Cập nhật thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi cập nhật hỗ trợ: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) print('Error cap nhat ho tro: $e');
      return false;
    }
  }
// ============================================================================
// CẬP NHẬT PHÂN PHÁT QUÀ
// ============================================================================
  Future<bool> capNhatPhanPhatQua({
    required int phanPhatID,
    required String trangThai,
    required String ngayPhanPhat,
    String? ghiChu,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final request = CapNhatPhanPhatQuaRequest(
        phanPhatID: phanPhatID,
        trangThai: trangThai,
        ngayPhanPhat: ngayPhanPhat,
        ghiChu: ghiChu,
      );

      final result = await _service.capNhatPhanPhatQua(request);

      _isLoading = false;

      if (result['success'] == true) {
        // Reload danh sách
        await loadDanhSachTreEm();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Cập nhật thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi cập nhật phân phát quà: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) print('Error cap nhat phan phat qua: $e');
      return false;
    }
  }

// ============================================================================
// FILTER VÀ SEARCH
// ============================================================================
  void changePhanPhatQuaFilter(String filter) {
    _filterPhanPhatQua = filter;
    loadDanhSachTreEm();
  }

  void searchPhanPhatQua(String query) {
    _searchQueryPhanPhatQua = query;
    loadDanhSachTreEm();
  }


  // LOAD PROFILE
  // ==========================================================================
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _service.getProfile();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
// ==========================================================================
// LOAD DANH SÁCH KHU PHỐ
// ==========================================================================
  Future<void> loadDanhSachKhuPho() async {
    try {
      _isLoadingKhuPho = true;
      _errorMessage = null;
      notifyListeners();

      _danhSachKhuPho = await _service.getDanhSachKhuPho();

      _isLoadingKhuPho = false;
      notifyListeners();
    } catch (e) {
      _isLoadingKhuPho = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

// ==========================================================================
// CẬP NHẬT THÔNG TIN TÀI KHOẢN
// ==========================================================================
  Future<void> capNhatThongTinTaiKhoan(UpdateProfileRequest request) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _service.capNhatThongTinTaiKhoan(request);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  // LOAD LỊCH SỬ HOẠT ĐỘNG
  Future<void> loadLichSuHoatDong({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
      }

      if (!_hasMoreData && !refresh) return;

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _service.getLichSuHoatDong(
        khuPho: _filterKhuPho,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _lichSuHoatDong = result;
      } else {
        // Append data
        if (_lichSuHoatDong != null) {
          _lichSuHoatDong = LichSuHoatDong(
            suKienDaThamGia: [
              ..._lichSuHoatDong!.suKienDaThamGia,
              ...result.suKienDaThamGia
            ],
            hoTroPhucLoiDaPhat: [
              ..._lichSuHoatDong!.hoTroPhucLoiDaPhat,
              ...result.hoTroPhucLoiDaPhat
            ],
            treEmDaVanDong: [
              ..._lichSuHoatDong!.treEmDaVanDong,
              ...result.treEmDaVanDong
            ],
            totalSuKien: result.totalSuKien,
            totalHoTro: result.totalHoTro,
            totalVanDong: result.totalVanDong,
            page: result.page,
            pageSize: result.pageSize,
          );
        } else {
          _lichSuHoatDong = result;
        }
      }

      // Check if has more data
      final totalItems = result.suKienDaThamGia.length +
          result.hoTroPhucLoiDaPhat.length +
          result.treEmDaVanDong.length;
      _hasMoreData = totalItems >= _pageSize;

      _currentPage++;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // SET FILTER KHU PHỐ
  void setFilterKhuPho(String? khuPho) {
    _filterKhuPho = khuPho;
    loadLichSuHoatDong(refresh: true);
  }

  // ĐỔI MẬT KHẨU
  // Future<void> doiMatKhau(String matKhauCu, String matKhauMoi) async {
  //   try {
  //     _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();
  //
  //     await _service.doiMatKhau(matKhauCu, matKhauMoi);
  //
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _isLoading = false;
  //     _errorMessage = e.toString();
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  // --- MẬT KHẨU ---
  Future<void> doiMatKhau(String matKhauCu, String matKhauMoi) async {
    await _service.doiMatKhau(matKhauCu, matKhauMoi);
  }

  // --- ĐĂNG XUẤT ---
  Future<void> dangXuat() async {
    await _service.dangXuat();
  }

  // ==========================================================================
  // CẬP NHẬT AVATAR
  // ==========================================================================
  Future<void> capNhatAvatar(File file) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newAvatar = await _service.capNhatAvatar(file);

      // Update profile
      if (_profile != null) {
        _profile = TinhNguyenVienProfile(
          userId: _profile!.userId,
          hoTen: _profile!.hoTen,
          sdt: _profile!.sdt,
          email: _profile!.email,
          vaiTro: _profile!.vaiTro,
          anh: newAvatar,
          ngayTao: _profile!.ngayTao,
          tinhNguyenVienID: _profile!.tinhNguyenVienID,
          ngaySinh: _profile!.ngaySinh,
          chucVu: _profile!.chucVu,
          tenKhuPho: _profile!.tenKhuPho,
          diaChiKhuPho: _profile!.diaChiKhuPho,
          quanHuyen: _profile!.quanHuyen,
          thanhPho: _profile!.thanhPho,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    await Future.wait([
      loadHome(),
      loadDanhSachSuKien(),
      loadDanhSachThongBao(),
      loadProfile(),
      loadLichTrong(),
      loadLichSuHoatDong(refresh: true),
    ]);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    _errorMessageSuKien = null;
    _errorMessageThongBao = null;
    notifyListeners();
  }

  // Clear all data (logout)
  void clear() {
    // Home
    _homeData = null;
    _lichTrong = null;
    _errorMessage = null;
    _isLoading = false;

    // Sự kiện
    _danhSachSuKien = [];
    _suKienChiTiet = null;
    _errorMessageSuKien = null;
    _isLoadingSuKien = false;
    _suKienFilter = 'TatCa';
    _suKienSearchQuery = '';

    // Thông báo
    _danhSachThongBao = [];
    _errorMessageThongBao = null;
    _isLoadingThongBao = false;
    _thongBaoFilter = 'TatCa';
    _soLuongChuaDoc = 0;

    // Trẻ em
    _treCanVanDong = [];
    _trePhanPhatQua = [];
    _chiTietTreVanDong = null;
    _chiTietTrePhanPhatQua = null;
    _filterPhanPhatQua = 'TatCa';
    _searchQueryPhanPhatQua = '';

    // Tài khoản


    notifyListeners();
  }
}