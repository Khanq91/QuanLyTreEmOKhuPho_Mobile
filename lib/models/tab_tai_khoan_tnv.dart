// File: models/tinh_nguyen_vien_profile.dart
// File: models/tab_tai_khoan_tnv.dart
// Thêm các class sau

// ==========================================================================
// KHU PHỐ DTO
// ==========================================================================
class KhuPhoDto {
  final int khuPhoId;
  final String tenKhuPho;
  final String? diaChi;
  final String? quanHuyen;
  final String? thanhPho;

  KhuPhoDto({
    required this.khuPhoId,
    required this.tenKhuPho,
    this.diaChi,
    this.quanHuyen,
    this.thanhPho,
  });

  factory KhuPhoDto.fromJson(Map<String, dynamic> json) {
    return KhuPhoDto(
      khuPhoId: json['khuPhoId'],
      tenKhuPho: json['tenKhuPho'],
      diaChi: json['diaChi'],
      quanHuyen: json['quanHuyen'],
      thanhPho: json['thanhPho'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'khuPhoId': khuPhoId,
      'tenKhuPho': tenKhuPho,
      'diaChi': diaChi,
      'quanHuyen': quanHuyen,
      'thanhPho': thanhPho,
    };
  }
}

// ==========================================================================
// UPDATE PROFILE REQUEST
// ==========================================================================
class UpdateProfileRequest {
  final String? hoTen;
  final String? sdt;
  final String? email;
  final DateTime? ngaySinh;
  final int? khuPhoId;
  final String? tenKhuPhoMoi;
  final String? diaChiKhuPho;
  final String? quanHuyen;
  final String? thanhPho;

  UpdateProfileRequest({
    this.hoTen,
    this.sdt,
    this.email,
    this.ngaySinh,
    this.khuPhoId,
    this.tenKhuPhoMoi,
    this.diaChiKhuPho,
    this.quanHuyen,
    this.thanhPho,
  });

  Map<String, dynamic> toJson() {
    return {
      if (hoTen != null) 'hoTen': hoTen,
      if (sdt != null) 'sdt': sdt,
      if (email != null) 'email': email,
      // if (ngaySinh != null) 'ngaySinh': ngaySinh!.toIso8601String(),
      if (ngaySinh != null)
        'ngaySinh': ngaySinh!.toIso8601String().split('T')[0],
      if (khuPhoId != null) 'khuPhoId': khuPhoId,
      if (tenKhuPhoMoi != null) 'tenKhuPhoMoi': tenKhuPhoMoi,
      if (diaChiKhuPho != null) 'diaChiKhuPho': diaChiKhuPho,
      if (quanHuyen != null) 'quanHuyen': quanHuyen,
      if (thanhPho != null) 'thanhPho': thanhPho,
    };
  }
}
class TinhNguyenVienProfile {
  final int userId;
  final String hoTen;
  final String sdt;
  final String email;
  final String vaiTro;
  final String? anh;
  final DateTime? ngayTao;
  final int tinhNguyenVienID;
  final DateTime? ngaySinh;
  final String? chucVu;
  final String? tenKhuPho;
  final String? diaChiKhuPho;
  final String? quanHuyen;
  final String? thanhPho;

  TinhNguyenVienProfile({
    required this.userId,
    required this.hoTen,
    required this.sdt,
    required this.email,
    required this.vaiTro,
    this.anh,
    this.ngayTao,
    required this.tinhNguyenVienID,
    this.ngaySinh,
    this.chucVu,
    this.tenKhuPho,
    this.diaChiKhuPho,
    this.quanHuyen,
    this.thanhPho,
  });

  factory TinhNguyenVienProfile.fromJson(Map<String, dynamic> json) {
    return TinhNguyenVienProfile(
      userId: json['userId'],
      hoTen: json['hoTen'] ?? '',
      sdt: json['sdt'] ?? '',
      email: json['email'] ?? '',
      vaiTro: json['vaiTro'] ?? '',
      anh: json['anh'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      tinhNguyenVienID: json['tinhNguyenVienID'],
      ngaySinh: json['ngaySinh'] != null ? DateTime.parse(json['ngaySinh']) : null,
      chucVu: json['chucVu'],
      tenKhuPho: json['tenKhuPho'],
      diaChiKhuPho: json['diaChiKhuPho'],
      quanHuyen: json['quanHuyen'],
      thanhPho: json['thanhPho'],
    );
  }
}

// File: models/lich_trong.dart
class LichTrong {
  final int lichTrongID;
  final int tinhNguyenVienID;
  final List<ChiTietLichTrong> chiTietLichTrongs;

  LichTrong({
    required this.lichTrongID,
    required this.tinhNguyenVienID,
    required this.chiTietLichTrongs,
  });

  factory LichTrong.fromJson(Map<String, dynamic> json) {
    return LichTrong(
      lichTrongID: json['lichTrongID'],
      tinhNguyenVienID: json['tinhNguyenVienID'],
      chiTietLichTrongs: (json['chiTietLichTrongs'] as List)
          .map((e) => ChiTietLichTrong.fromJson(e))
          .toList(),
    );
  }
}

class ChiTietLichTrong {
  final int chiTietLichTrongID;
  final String buoi;
  final String thu;

  ChiTietLichTrong({
    required this.chiTietLichTrongID,
    required this.buoi,
    required this.thu,
  });

  factory ChiTietLichTrong.fromJson(Map<String, dynamic> json) {
    return ChiTietLichTrong(
      chiTietLichTrongID: json['chiTietLichTrongID'],
      buoi: json['buoi'],
      thu: json['thu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buoi': buoi,
      'thu': thu,
    };
  }
}

// File: models/lich_su_hoat_dong.dart
class LichSuHoatDong {
  final List<SuKienDaThamGia> suKienDaThamGia;
  // final List<HoTroPhucLoiDaPhat> hoTroPhucLoiDaPhat;
  final List<QuaPhanPhatInfo> quaDaPhanPhat;
  final List<TreEmDaVanDong> treEmDaVanDong;
  final int totalSuKien;
  final int totalQuaPhanPhat;
  // final int totalHoTro;
  final int totalVanDong;
  final int page;
  final int pageSize;

  LichSuHoatDong({
    required this.suKienDaThamGia,
    // required this.hoTroPhucLoiDaPhat,
    required this.quaDaPhanPhat,
    required this.treEmDaVanDong,
    required this.totalSuKien,
    required this.totalQuaPhanPhat,
    // required this.totalHoTro,
    required this.totalVanDong,
    required this.page,
    required this.pageSize,
  });

  factory LichSuHoatDong.fromJson(Map<String, dynamic> json) {
    return LichSuHoatDong(
      suKienDaThamGia: (json['suKienDaThamGia'] as List)
          .map((e) => SuKienDaThamGia.fromJson(e))
          .toList(),
      // hoTroPhucLoiDaPhat: (json['hoTroPhucLoiDaPhat'] as List)
      //     .map((e) => HoTroPhucLoiDaPhat.fromJson(e))
      //     .toList(),
      quaDaPhanPhat: (json['quaDaPhanPhat'] as List)
          .map((e) => QuaPhanPhatInfo.fromJson(e))
          .toList(),
      treEmDaVanDong: (json['treEmDaVanDong'] as List)
          .map((e) => TreEmDaVanDong.fromJson(e))
          .toList(),
      totalSuKien: json['totalSuKien'],
      totalQuaPhanPhat: json['totalQuaPhanPhat'],
      totalVanDong: json['totalVanDong'],
      page: json['page'],
      pageSize: json['pageSize'],
    );
  }
}

class SuKienDaThamGia {
  final int suKienID;
  final String tenSuKien;
  final String? diaDiem;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String? tenKhuPho;
  final DateTime? ngayDangKy;

  SuKienDaThamGia({
    required this.suKienID,
    required this.tenSuKien,
    this.diaDiem,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.tenKhuPho,
    this.ngayDangKy,
  });

  factory SuKienDaThamGia.fromJson(Map<String, dynamic> json) {
    return SuKienDaThamGia(
      suKienID: json['suKienID'],
      tenSuKien: json['tenSuKien'] ?? '',
      diaDiem: json['diaDiem'],
      ngayBatDau: json['ngayBatDau'] != null ? DateTime.parse(json['ngayBatDau']) : null,
      ngayKetThuc: json['ngayKetThuc'] != null ? DateTime.parse(json['ngayKetThuc']) : null,
      tenKhuPho: json['tenKhuPho'],
      ngayDangKy: json['ngayDangKy'] != null ? DateTime.parse(json['ngayDangKy']) : null,
    );
  }
}

class HoTroPhucLoiDaPhat {
  final int hoTroID;
  final String loaiHoTro;
  final String? moTa;
  final DateTime? ngayCap;
  final String? tenTreEm;
  final String? tenKhuPho;
  final String? trangThaiPhat;

  HoTroPhucLoiDaPhat({
    required this.hoTroID,
    required this.loaiHoTro,
    this.moTa,
    this.ngayCap,
    this.tenTreEm,
    this.tenKhuPho,
    this.trangThaiPhat,
  });

  factory HoTroPhucLoiDaPhat.fromJson(Map<String, dynamic> json) {
    return HoTroPhucLoiDaPhat(
      hoTroID: json['hoTroID'],
      loaiHoTro: json['loaiHoTro'] ?? '',
      moTa: json['moTa'],
      ngayCap: json['ngayCap'] != null ? DateTime.parse(json['ngayCap']) : null,
      tenTreEm: json['tenTreEm'],
      tenKhuPho: json['tenKhuPho'],
      trangThaiPhat: json['trangThaiPhat'],
    );
  }
}

class QuaPhanPhatInfo {
  final int phanPhatID;
  final String tenQua;
  final String moTa;
  final int soLuongNhan;
  final String ngayPhanPhat;
  final String nguoiPhanPhat;
  final String trangThai;
  final String anh;
  final int? suKienID;
  final String? tenSuKien;
  final String? tenTreEm;
  final int? treEmId;

  QuaPhanPhatInfo({
    required this.phanPhatID,
    required this.tenQua,
    required this.moTa,
    required this.soLuongNhan,
    required this.ngayPhanPhat,
    required this.nguoiPhanPhat,
    required this.trangThai,
    required this.anh,
    this.suKienID,
    this.tenSuKien,
    this.tenTreEm,
    this.treEmId,
  });

  factory QuaPhanPhatInfo.fromJson(Map<String, dynamic> json) {
    return QuaPhanPhatInfo(
      phanPhatID: json['phanPhatID'] ?? 0,
      tenQua: json['tenQua'] ?? '',
      moTa: json['moTa'] ?? '',
      soLuongNhan: json['soLuongNhan'] ?? 1,
      ngayPhanPhat: json['ngayPhanPhat'] ?? '',
      nguoiPhanPhat: json['nguoiPhanPhat'] ?? '',
      trangThai: json['trangThai'] ?? '',
      anh: json['anh'] ?? '',
      suKienID: json['suKienID'],
      tenSuKien: json['tenSuKien'],
      tenTreEm: json['tenTreEm'],
      treEmId: json['treEmId'],
    );
  }
}

class TreEmDaVanDong {
  final int vanDongID;
  final String tenTreEm;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? tenKhuPho;
  final String? loaiHoanCanh;
  final int? soLan;
  final String? lyDo;
  final String? ketQua;
  final DateTime? ngayVanDong;
  final String? tinhTrangCapNhat;
  final String? ghiChuChiTiet;

  TreEmDaVanDong({
    required this.vanDongID,
    required this.tenTreEm,
    this.ngaySinh,
    this.gioiTinh,
    this.tenKhuPho,
    this.loaiHoanCanh,
    this.soLan,
    this.lyDo,
    this.ketQua,
    this.ngayVanDong,
    this.tinhTrangCapNhat,
    this.ghiChuChiTiet,
  });

  factory TreEmDaVanDong.fromJson(Map<String, dynamic> json) {
    return TreEmDaVanDong(
      vanDongID: json['vanDongID'],
      tenTreEm: json['tenTreEm'] ?? '',
      ngaySinh: json['ngaySinh'] != null ? DateTime.parse(json['ngaySinh']) : null,
      gioiTinh: json['gioiTinh'],
      tenKhuPho: json['tenKhuPho'],
      loaiHoanCanh: json['loaiHoanCanh'],
      soLan: json['soLan'],
      lyDo: json['lyDo'],
      ketQua: json['ketQua'],
      ngayVanDong: json['ngayVanDong'] != null ? DateTime.parse(json['ngayVanDong']) : null,
      tinhTrangCapNhat: json['tinhTrangCapNhat'],
      ghiChuChiTiet: json['ghiChuChiTiet'],
    );
  }
}