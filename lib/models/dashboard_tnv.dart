// models/tinh_nguyen_vien_home_model.dart
class TinhNguyenVienHomeModel {
  final ThongTinTaiKhoanModel thongTinTaiKhoan;
  final List<SuKienPhanCongModel> suKienPhanCong;
  final ThongKeHoatDongModel thongKe;
  final LichTrongModel lichTrong;

  TinhNguyenVienHomeModel({
    required this.thongTinTaiKhoan,
    required this.suKienPhanCong,
    required this.thongKe,
    required this.lichTrong,
  });

  factory TinhNguyenVienHomeModel.fromJson(Map<String, dynamic> json) {
    return TinhNguyenVienHomeModel(
      thongTinTaiKhoan: ThongTinTaiKhoanModel.fromJson(json['thongTinTaiKhoan']),
      suKienPhanCong: (json['suKienPhanCong'] as List)
          .map((e) => SuKienPhanCongModel.fromJson(e))
          .toList(),
      thongKe: ThongKeHoatDongModel.fromJson(json['thongKe']),
      lichTrong: LichTrongModel.fromJson(json['lichTrong']),
    );
  }
}

// models/thong_tin_tai_khoan_model.dart
class ThongTinTaiKhoanModel {
  final int userId;
  final int tinhNguyenVienId;
  final String hoTen;
  final String chucVu;
  final String sdt;
  final String? avatar;
  final String vaiTro;

  ThongTinTaiKhoanModel({
    required this.userId,
    required this.tinhNguyenVienId,
    required this.hoTen,
    required this.chucVu,
    required this.sdt,
    this.avatar,
    required this.vaiTro,
  });

  factory ThongTinTaiKhoanModel.fromJson(Map<String, dynamic> json) {
    return ThongTinTaiKhoanModel(
      userId: json['userId'],
      tinhNguyenVienId: json['tinhNguyenVienId'],
      hoTen: json['hoTen'],
      chucVu: json['chucVu'],
      sdt: json['sdt'],
      avatar: json['avatar'],
      vaiTro: json['vaiTro'],
    );
  }
}

// models/su_kien_phan_cong_model.dart
class SuKienPhanCongModel {
  final int suKienId;
  final String tenSuKien;
  final String congViec;
  final DateTime ngayPhanCong;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final String trangThai;
  final String diaDiem;

  SuKienPhanCongModel({
    required this.suKienId,
    required this.tenSuKien,
    required this.congViec,
    required this.ngayPhanCong,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.trangThai,
    required this.diaDiem,
  });

  factory SuKienPhanCongModel.fromJson(Map<String, dynamic> json) {
    return SuKienPhanCongModel(
      suKienId: json['suKienId'],
      tenSuKien: json['tenSuKien'],
      congViec: json['congViec'],
      ngayPhanCong: DateTime.parse(json['ngayPhanCong']),
      ngayBatDau: DateTime.parse(json['ngayBatDau']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      trangThai: json['trangThai'],
      diaDiem: json['diaDiem'],
    );
  }
}

// models/thong_ke_hoat_dong_model.dart
class ThongKeHoatDongModel {
  final int tongSuKienThamGia;
  final List<SuKienDaThamGiaModel> suKienGanDay;

  ThongKeHoatDongModel({
    required this.tongSuKienThamGia,
    required this.suKienGanDay,
  });

  factory ThongKeHoatDongModel.fromJson(Map<String, dynamic> json) {
    return ThongKeHoatDongModel(
      tongSuKienThamGia: json['tongSuKienThamGia'],
      suKienGanDay: (json['suKienGanDay'] as List)
          .map((e) => SuKienDaThamGiaModel.fromJson(e))
          .toList(),
    );
  }
}

class SuKienDaThamGiaModel {
  final int suKienId;
  final String tenSuKien;
  final String nguoiChiuTrachNhiem;
  final String moTa;
  final String diaDiem;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;

  SuKienDaThamGiaModel({
    required this.suKienId,
    required this.tenSuKien,
    required this.nguoiChiuTrachNhiem,
    required this.moTa,
    required this.diaDiem,
    required this.ngayBatDau,
    required this.ngayKetThuc,
  });

  factory SuKienDaThamGiaModel.fromJson(Map<String, dynamic> json) {
    return SuKienDaThamGiaModel(
      suKienId: json['suKienId'],
      tenSuKien: json['tenSuKien'],
      nguoiChiuTrachNhiem: json['nguoiChiuTrachNhiem'],
      moTa: json['moTa'],
      diaDiem: json['diaDiem'],
      ngayBatDau: DateTime.parse(json['ngayBatDau']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
    );
  }
}

// models/lich_trong_model.dart
class LichTrongModel {
  final int? lichTrongId;
  final bool isEmpty;
  final List<ChiTietLichTrongModel> chiTietLichTrong;

  LichTrongModel({
    this.lichTrongId,
    required this.isEmpty,
    required this.chiTietLichTrong,
  });

  factory LichTrongModel.fromJson(Map<String, dynamic> json) {
    return LichTrongModel(
      lichTrongId: json['lichTrongId'],
      isEmpty: json['isEmpty'],
      chiTietLichTrong: (json['chiTietLichTrong'] as List)
          .map((e) => ChiTietLichTrongModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chiTietLichTrong': chiTietLichTrong.map((e) => e.toJson()).toList(),
    };
  }
}

class ChiTietLichTrongModel {
  final String thu;
  final String buoi;
  final bool isAvailable;

  ChiTietLichTrongModel({
    required this.thu,
    required this.buoi,
    required this.isAvailable,
  });

  factory ChiTietLichTrongModel.fromJson(Map<String, dynamic> json) {
    return ChiTietLichTrongModel(
      thu: json['thu'],
      buoi: json['buoi'],
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thu': thu,
      'buoi': buoi,
      'isAvailable': isAvailable,
    };
  }

  ChiTietLichTrongModel copyWith({bool? isAvailable}) {
    return ChiTietLichTrongModel(
      thu: thu,
      buoi: buoi,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}