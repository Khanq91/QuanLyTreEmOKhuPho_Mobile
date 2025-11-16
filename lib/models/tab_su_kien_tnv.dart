

class SuKienListDto {
  final int suKienId;
  final String tenSuKien;
  final String? moTa;
  final String diaDiem;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final int soLuongTinhNguyenVien;
  final int soLuongTreEm;
  final String nguoiChiuTrachNhiem;
  final String tenKhuPho;
  final int? dangKyId;
  final String? trangThaiDangKy; // "Đã duyệt", "Chờ duyệt", "Từ chối"
  final String? congViecPhanCong;
  final bool daPhanCong;
  final int soLuongDaDangKy; // Số lượng TNV đã đăng ký (để check đủ chưa)

  SuKienListDto({
    required this.suKienId,
    required this.tenSuKien,
    this.moTa,
    required this.diaDiem,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.soLuongTinhNguyenVien,
    required this.soLuongTreEm,
    required this.nguoiChiuTrachNhiem,
    required this.tenKhuPho,
    this.dangKyId,
    this.trangThaiDangKy,
    this.congViecPhanCong,
    required this.daPhanCong,
    required this.soLuongDaDangKy,
  });

  factory SuKienListDto.fromJson(Map<String, dynamic> json) {
    return SuKienListDto(
      suKienId: json['suKienId'] ?? 0,
      tenSuKien: json['tenSuKien'] ?? '',
      moTa: json['moTa'],
      diaDiem: json['diaDiem'] ?? '',
      ngayBatDau: DateTime.parse(json['ngayBatDau']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      soLuongTinhNguyenVien: json['soLuongTinhNguyenVien'] ?? 0,
      soLuongTreEm: json['soLuongTreEm'] ?? 0,
      nguoiChiuTrachNhiem: json['nguoiChiuTrachNhiem'] ?? '',
      tenKhuPho: json['tenKhuPho'] ?? '',
      dangKyId: json['dangKyId'],
      trangThaiDangKy: json['trangThaiDangKy'],
      congViecPhanCong: json['congViecPhanCong'],
      daPhanCong: json['daPhanCong'] ?? false,
      soLuongDaDangKy: json['soLuongDaDangKy'] ?? 0,
    );
  }

  // Helper getters
  bool get daHetHan => DateTime.now().isAfter(ngayKetThuc);
  bool get daDangKy => dangKyId != null;
  bool get choPheDuyet => trangThaiDangKy == 'Chờ duyệt';
  bool get daDuyet => trangThaiDangKy == 'Đã duyệt';
  bool get biTuChoi => trangThaiDangKy == 'Từ chối';
  bool get daDay => soLuongDaDangKy >= soLuongTinhNguyenVien;
  bool get coTheDangKy => !daHetHan && !daDangKy && !daDay;
}

class SuKienChiTietDto {
  final int suKienId;
  final String tenSuKien;
  final String? moTa;
  final String diaDiem;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final int soLuongTinhNguyenVien;
  final int soLuongTreEm;
  final String nguoiChiuTrachNhiem;
  final String tenKhuPho;
  final String diaChiKhuPho;
  final int? dangKyId;
  final String? trangThaiDangKy;
  final DateTime? ngayDangKy;
  final String? congViecPhanCong;
  final String? ghiChuPhanCong;
  final DateTime? ngayPhanCong;
  final List<ThoiGianChiTietDto> thoiGianChiTiet;
  final int soLuongDaDangKy;

  SuKienChiTietDto({
    required this.suKienId,
    required this.tenSuKien,
    this.moTa,
    required this.diaDiem,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.soLuongTinhNguyenVien,
    required this.soLuongTreEm,
    required this.nguoiChiuTrachNhiem,
    required this.tenKhuPho,
    required this.diaChiKhuPho,
    this.dangKyId,
    this.trangThaiDangKy,
    this.ngayDangKy,
    this.congViecPhanCong,
    this.ghiChuPhanCong,
    this.ngayPhanCong,
    required this.thoiGianChiTiet,
    required this.soLuongDaDangKy,
  });

  factory SuKienChiTietDto.fromJson(Map<String, dynamic> json) {
    return SuKienChiTietDto(
      suKienId: json['suKienId'] ?? 0,
      tenSuKien: json['tenSuKien'] ?? '',
      moTa: json['moTa'],
      diaDiem: json['diaDiem'] ?? '',
      ngayBatDau: DateTime.parse(json['ngayBatDau']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      soLuongTinhNguyenVien: json['soLuongTinhNguyenVien'] ?? 0,
      soLuongTreEm: json['soLuongTreEm'] ?? 0,
      nguoiChiuTrachNhiem: json['nguoiChiuTrachNhiem'] ?? '',
      tenKhuPho: json['tenKhuPho'] ?? '',
      diaChiKhuPho: json['diaChiKhuPho'] ?? '',
      dangKyId: json['dangKyId'],
      trangThaiDangKy: json['trangThaiDangKy'],
      ngayDangKy: json['ngayDangKy'] != null ? DateTime.parse(json['ngayDangKy']) : null,
      congViecPhanCong: json['congViecPhanCong'],
      ghiChuPhanCong: json['ghiChuPhanCong'],
      ngayPhanCong: json['ngayPhanCong'] != null ? DateTime.parse(json['ngayPhanCong']) : null,
      thoiGianChiTiet: (json['thoiGianChiTiet'] as List<dynamic>?)
          ?.map((e) => ThoiGianChiTietDto.fromJson(e))
          .toList() ?? [],
      soLuongDaDangKy: json['soLuongDaDangKy'] ?? 0,
    );
  }

  bool get daHetHan => DateTime.now().isAfter(ngayKetThuc);
  bool get daDangKy => dangKyId != null;
  bool get choPheDuyet => trangThaiDangKy == 'Chờ duyệt';
  bool get daDuyet => trangThaiDangKy == 'Đã duyệt';
  bool get biTuChoi => trangThaiDangKy == 'Từ chối';
  bool get daDay => soLuongDaDangKy >= soLuongTinhNguyenVien;
  bool get coTheDangKy => !daHetHan && !daDangKy && !daDay;
  bool get daPhanCong => congViecPhanCong != null;
}

class ThoiGianChiTietDto {
  final int thoiGianChiTietSuKienId;
  final String? moTa;
  final DateTime thoiGianBatDau;
  final DateTime thoiGianKetThuc;

  ThoiGianChiTietDto({
    required this.thoiGianChiTietSuKienId,
    this.moTa,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
  });

  factory ThoiGianChiTietDto.fromJson(Map<String, dynamic> json) {
    return ThoiGianChiTietDto(
      thoiGianChiTietSuKienId: json['thoiGianChiTietSuKienId'] ?? 0,
      moTa: json['moTa'],
      thoiGianBatDau: DateTime.parse(json['thoiGianBatDau']),
      thoiGianKetThuc: DateTime.parse(json['thoiGianKetThuc']),
    );
  }
}

class DangKySuKienRequest {
  final int suKienId;

  DangKySuKienRequest({required this.suKienId});

  Map<String, dynamic> toJson() => {'suKienId': suKienId};
}

class HuyDangKySuKienRequest {
  final int dangKyId;
  final String lyDo;

  HuyDangKySuKienRequest({
    required this.dangKyId,
    required this.lyDo,
  });

  Map<String, dynamic> toJson() => {
    'dangKyId': dangKyId,
    'lyDo': lyDo,
  };
}