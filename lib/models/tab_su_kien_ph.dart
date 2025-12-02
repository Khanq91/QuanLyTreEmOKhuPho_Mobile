class DanhSachSuKien {
  final int suKienId;
  final String tenSuKien;
  final String ngayBatDau;
  final String ngayKetThuc;
  final String diaDiem;
  final String tenKhuPho;
  final bool daDangKy;
  final String trangThaiDangKy;

  DanhSachSuKien({
    required this.suKienId,
    required this.tenSuKien,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.diaDiem,
    required this.tenKhuPho,
    required this.daDangKy,
    required this.trangThaiDangKy,
  });

  factory DanhSachSuKien.fromJson(Map<String, dynamic> json) {
    return DanhSachSuKien(
      suKienId: json['suKienId'] ?? 0,
      tenSuKien: json['tenSuKien'] ?? '',
      ngayBatDau: json['ngayBatDau'] ?? '',
      ngayKetThuc: json['ngayKetThuc'] ?? '',
      diaDiem: json['diaDiem'] ?? '',
      tenKhuPho: json['tenKhuPho'] ?? '',
      daDangKy: json['daDangKy'] ?? false,
      trangThaiDangKy: json['trangThaiDangKy'] ?? '',
    );
  }
}

class TietMucInfo {
  final int tietMucId;
  final String tenTietMuc;
  final String nguoiThucHien;

  TietMucInfo({
    required this.tietMucId,
    required this.tenTietMuc,
    required this.nguoiThucHien,
  });

  factory TietMucInfo.fromJson(Map<String, dynamic> json) {
    return TietMucInfo(
      tietMucId: json['tietMucId'] ?? 0,
      tenTietMuc: json['tenTietMuc'] ?? '',
      nguoiThucHien: json['nguoiThucHien'] ?? '',
    );
  }
}

class ChuongTrinhSuKien {
  final int thoiGianChiTietSuKienId;
  final String moTa;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final List<TietMucInfo> danhSachTietMuc;

  ChuongTrinhSuKien({
    required this.thoiGianChiTietSuKienId,
    required this.moTa,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.danhSachTietMuc,
  });

  factory ChuongTrinhSuKien.fromJson(Map<String, dynamic> json) {
    var tietMucList = json['danhSachTietMuc'] as List;
    List<TietMucInfo> tietMucs = tietMucList.map((i) => TietMucInfo.fromJson(i)).toList();

    return ChuongTrinhSuKien(
      thoiGianChiTietSuKienId: json['thoiGianChiTietSuKienId'] ?? 0,
      moTa: json['moTa'] ?? '',
      thoiGianBatDau: json['thoiGianBatDau'] ?? '',
      thoiGianKetThuc: json['thoiGianKetThuc'] ?? '',
      danhSachTietMuc: tietMucs,
    );
  }
}

class ChiTietSuKienResponse {
  final int suKienId;
  final String tenSuKien;
  final String moTa;
  final String diaDiem;
  final String ngayBatDau;
  final String ngayKetThuc;
  final int soLuongTinhNguyenVien;
  final int soLuongTreEm;
  final String nguoiChiuTrachNhiem;
  final String tenKhuPho;
  final String diaChiKhuPho;
  final String? anhSuKien;
  final bool daDangKy;
  final String trangThaiDangKy;
  final List<ChuongTrinhSuKien> danhSachChuongTrinh;

  ChiTietSuKienResponse({
    required this.suKienId,
    required this.tenSuKien,
    required this.moTa,
    required this.diaDiem,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.soLuongTinhNguyenVien,
    required this.soLuongTreEm,
    required this.nguoiChiuTrachNhiem,
    required this.tenKhuPho,
    required this.diaChiKhuPho,
    required this.anhSuKien,
    required this.daDangKy,
    required this.trangThaiDangKy,
    required this.danhSachChuongTrinh,
  });

  factory ChiTietSuKienResponse.fromJson(Map<String, dynamic> json) {
    var chuongTrinhList = json['danhSachChuongTrinh'] as List;
    List<ChuongTrinhSuKien> chuongTrinhs = chuongTrinhList.map((i) => ChuongTrinhSuKien.fromJson(i)).toList();

    return ChiTietSuKienResponse(
      suKienId: json['suKienId'] ?? 0,
      tenSuKien: json['tenSuKien'] ?? '',
      moTa: json['moTa'] ?? '',
      diaDiem: json['diaDiem'] ?? '',
      ngayBatDau: json['ngayBatDau'] ?? '',
      ngayKetThuc: json['ngayKetThuc'] ?? '',
      soLuongTinhNguyenVien: json['soLuongTinhNguyenVien'] ?? 0,
      soLuongTreEm: json['soLuongTreEm'] ?? 0,
      nguoiChiuTrachNhiem: json['nguoiChiuTrachNhiem'] ?? '',
      tenKhuPho: json['tenKhuPho'] ?? '',
      diaChiKhuPho: json['diaChiKhuPho'] ?? '',
      anhSuKien: json['anhSuKien'],
      daDangKy: json['daDangKy'] ?? false,
      trangThaiDangKy: json['trangThaiDangKy'] ?? '',
      danhSachChuongTrinh: chuongTrinhs,
    );
  }
}

class DangKySuKienResponse {
  final bool success;
  final String message;
  final String trangThai;

  DangKySuKienResponse({
    required this.success,
    required this.message,
    required this.trangThai,
  });

  factory DangKySuKienResponse.fromJson(Map<String, dynamic> json) {
    return DangKySuKienResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      trangThai: json['trangThai'] ?? '',
    );
  }
}