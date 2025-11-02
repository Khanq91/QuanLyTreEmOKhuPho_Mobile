//tinh nguyen vien providers

import 'package:flutter/material.dart';


class TinhNguyenVienProvider extends ChangeNotifier {
  // final VolunteerService _service = VolunteerService();
  //
  // DashboardTinhNguyenVien? _dashboard;
  // // List<SuKien> _suKiens = [];
  // List<LichTrong> _lichTrong = [];
  // List<TreEm> _treEmVanDong = [];
  // List<TreEm> _treEmHoTro = [];
  // List<ThongBao> _thongBaos = [];
  // Map<String, dynamic>? _lichSuHoatDong;
  // bool _isLoading = false;
  // String? _errorMessage;
  //
  // DashboardTinhNguyenVien? get dashboard => _dashboard;
  // // List<SuKien> get suKiens => _suKiens;
  // List<LichTrong> get lichTrong => _lichTrong;
  // List<TreEm> get treEmVanDong => _treEmVanDong;
  // List<TreEm> get treEmHoTro => _treEmHoTro;
  // List<ThongBao> get thongBaos => _thongBaos;
  // Map<String, dynamic>? get lichSuHoatDong => _lichSuHoatDong;
  // bool get isLoading => _isLoading;
  // String? get errorMessage => _errorMessage;
  //
  // int get unreadNotificationCount {
  //   return _thongBaos.where((t) => !t.daDoc).length;
  // }
  //
  // Future<void> loadDashboard() async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     _dashboard = await _service.getDashboard();
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
  //
  // // Future<void> loadSuKien({String? boLoc}) async {
  // //   _isLoading = true;
  // //   _errorMessage = null;
  // //   notifyListeners();
  // //
  // //   try {
  // //     _suKiens = await _service.getSuKien(boLoc: boLoc);
  // //     _isLoading = false;
  // //     notifyListeners();
  // //   } catch (e) {
  // //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  // //     _isLoading = false;
  // //     notifyListeners();
  // //   }
  // // }
  // //
  // // Future<SuKien?> loadChiTietSuKien(int suKienId) async {
  // //   try {
  // //     return await _service.getChiTietSuKien(suKienId);
  // //   } catch (e) {
  // //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  // //     notifyListeners();
  // //     return null;
  // //   }
  // // }
  //
  // Future<void> loadLichTrong() async {
  //   try {
  //     _lichTrong = await _service.getLichTrong();
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> loadTreEmVanDong() async {
  //   try {
  //     _treEmVanDong = await _service.getTreEmVanDong();
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> loadTreEmHoTro() async {
  //   try {
  //     _treEmHoTro = await _service.getTreEmHoTro();
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> loadThongBao() async {
  //   try {
  //     _thongBaos = await _service.getThongBao();
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> loadLichSuHoatDong() async {
  //   try {
  //     _lichSuHoatDong = await _service.getLichSuHoatDong();
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //   }
  // }
  //
  // Future<bool> dangKySuKien(int suKienId) async {
  //   try {
  //     final success = await _service.dangKySuKien(suKienId);
  //     if (success) {
  //       await loadSuKien(); // Refresh
  //     }
  //     return success;
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //     return false;
  //   }
  // }
  //
  // Future<bool> checkInSuKien(int suKienId) async {
  //   try {
  //     return await _service.checkInSuKien(suKienId);
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //     return false;
  //   }
  // }
  //
  // Future<bool> capNhatLichTrong({
  //   required DateTime tuanBatDau,
  //   required List<String> buoiTrong,
  // }) async {
  //   try {
  //     final success = await _service.capNhatLichTrong(
  //       tuanBatDau: tuanBatDau,
  //       buoiTrong: buoiTrong,
  //     );
  //     if (success) {
  //       await loadLichTrong(); // Refresh
  //     }
  //     return success;
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //     return false;
  //   }
  // }
  //
  // Future<bool> capNhatTinhTrangVanDong({
  //   required int treEmId,
  //   required String tinhTrang,
  //   required String lyDo,
  //   String? ghiChu,
  //   String? anhMinhChung,
  // }) async {
  //   try {
  //     final success = await _service.capNhatTinhTrangVanDong(
  //       treEmId: treEmId,
  //       tinhTrang: tinhTrang,
  //       lyDo: lyDo,
  //       ghiChu: ghiChu,
  //       anhMinhChung: anhMinhChung,
  //     );
  //     if (success) {
  //       await loadTreEmVanDong(); // Refresh
  //     }
  //     return success;
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //     return false;
  //   }
  // }
  //
  // Future<bool> capNhatTinhTrangHoTro({
  //   required int hoTroId,
  //   required String tinhTrang,
  //   DateTime? ngayHenTai,
  //   String? ghiChu,
  //   required String anhMinhChung,
  // }) async {
  //   try {
  //     final success = await _service.capNhatTinhTrangHoTro(
  //       hoTroId: hoTroId,
  //       tinhTrang: tinhTrang,
  //       ngayHenTai: ngayHenTai,
  //       ghiChu: ghiChu,
  //       anhMinhChung: anhMinhChung,
  //     );
  //     if (success) {
  //       await loadTreEmHoTro(); // Refresh
  //     }
  //     return success;
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     notifyListeners();
  //     return false;
  //   }
  // }
  //
  // Future<bool> markThongBaoAsRead(int thongBaoId) async {
  //   try {
  //     final success = await _service.markThongBaoAsRead(thongBaoId);
  //     if (success) {
  //       await loadThongBao(); // Reload
  //     }
  //     return success;
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     return false;
  //   }
  // }
  //
  // Future<bool> updateThongTinCaNhan(Map<String, dynamic> data) async {
  //   try {
  //     final success = await _service.updateThongTinCaNhan(data);
  //     if (success) {
  //       await loadDashboard(); // Refresh
  //     }
  //     return success;
  //   } catch (e) {
  //     _errorMessage = e.toString().replaceAll('Exception: ', '');
  //     return false;
  //   }
  // }
  //
  // void clearError() {
  //   _errorMessage = null;
  //   notifyListeners();
  // }
}