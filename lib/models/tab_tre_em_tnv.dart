// File: lib/models/tnv/tre_em_models.dart

class TreEmCanVanDong {
  final int treEmID;
  final String hoTen;
  final DateTime ngaySinh;
  final String gioiTinh;
  final String diaChi;
  final String tinhTrang;
  final int soLanVanDong;
  final String? anh;

  TreEmCanVanDong({
    required this.treEmID,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.diaChi,
    required this.tinhTrang,
    required this.soLanVanDong,
    this.anh,
  });

  factory TreEmCanVanDong.fromJson(Map<String, dynamic> json) {
    return TreEmCanVanDong(
      treEmID: json['treEmID'],
      hoTen: json['hoTen'],
      ngaySinh: DateTime.parse(json['ngaySinh']),
      gioiTinh: json['gioiTinh'],
      diaChi: json['diaChi'] ?? '',
      tinhTrang: json['tinhTrang'] ?? 'Chưa cập nhật',
      soLanVanDong: json['soLanVanDong'] ?? 0,
      anh: json['anh'],
    );
  }
}

class TreEmPhatHoTro {
  final int treEmID;
  final int hoTroID;
  final String hoTen;
  final DateTime ngaySinh;
  final String gioiTinh;
  final String diaChi;
  final String trangThaiPhat;
  final String loaiHoTro;
  final DateTime? ngayHenLai;
  final String? anh;

  TreEmPhatHoTro({
    required this.treEmID,
    required this.hoTroID,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.diaChi,
    required this.trangThaiPhat,
    required this.loaiHoTro,
    this.ngayHenLai,
    this.anh,
  });

  factory TreEmPhatHoTro.fromJson(Map<String, dynamic> json) {
    return TreEmPhatHoTro(
      treEmID: json['treEmID'],
      hoTroID: json['hoTroID'],
      hoTen: json['hoTen'],
      ngaySinh: DateTime.parse(json['ngaySinh']),
      gioiTinh: json['gioiTinh'],
      diaChi: json['diaChi'] ?? '',
      trangThaiPhat: json['trangThaiPhat'] ?? 'Lần đầu',
      loaiHoTro: json['loaiHoTro'],
      ngayHenLai: json['ngayHenLai'] != null
          ? DateTime.parse(json['ngayHenLai'])
          : null,
      anh: json['anh'],
    );
  }
}

class DanhSachTreEmResponse {
  final List<TreEmCanVanDong> treCanVanDong;
  final List<TreEmPhatHoTro> trePhatHoTro;

  DanhSachTreEmResponse({
    required this.treCanVanDong,
    required this.trePhatHoTro,
  });

  factory DanhSachTreEmResponse.fromJson(Map<String, dynamic> json) {
    return DanhSachTreEmResponse(
      treCanVanDong: (json['treCanVanDong'] as List)
          .map((e) => TreEmCanVanDong.fromJson(e))
          .toList(),
      trePhatHoTro: (json['trePhatHoTro'] as List)
          .map((e) => TreEmPhatHoTro.fromJson(e))
          .toList(),
    );
  }
}

class ThongTinPhuHuynh {
  final int phuHuynhID;
  final String hoTen;
  final String sdt;
  final String diaChi;
  final String ngheNghiep;
  final String moiQuanHe;

  ThongTinPhuHuynh({
    required this.phuHuynhID,
    required this.hoTen,
    required this.sdt,
    required this.diaChi,
    required this.ngheNghiep,
    required this.moiQuanHe,
  });

  factory ThongTinPhuHuynh.fromJson(Map<String, dynamic> json) {
    return ThongTinPhuHuynh(
      phuHuynhID: json['phuHuynhID'],
      hoTen: json['hoTen'],
      sdt: json['sdt'],
      diaChi: json['diaChi'],
      ngheNghiep: json['ngheNghiep'],
      moiQuanHe: json['moiQuanHe'],
    );
  }
}

class LichSuVanDong {
  final int vanDongID;
  final String tinhTrangCapNhat;
  final String ghiChuChiTiet;
  final String? anhMinhChung;
  final DateTime ngayCapNhat;
  final int soLan;

  LichSuVanDong({
    required this.vanDongID,
    required this.tinhTrangCapNhat,
    required this.ghiChuChiTiet,
    this.anhMinhChung,
    required this.ngayCapNhat,
    required this.soLan,
  });

  factory LichSuVanDong.fromJson(Map<String, dynamic> json) {
    return LichSuVanDong(
      vanDongID: json['vanDongID'],
      tinhTrangCapNhat: json['tinhTrangCapNhat'],
      ghiChuChiTiet: json['ghiChuChiTiet'] ?? '',
      anhMinhChung: json['anhMinhChung'],
      ngayCapNhat: DateTime.parse(json['ngayCapNhat']),
      soLan: json['soLan'],
    );
  }
}

class ChiTietTreEmVanDong {
  final int treEmID;
  final String hoTen;
  final DateTime ngaySinh;
  final String gioiTinh;
  final String tonGiao;
  final String danToc;
  final String? anh;
  final List<ThongTinPhuHuynh> danhSachPhuHuynh;
  final int hoanCanhID;
  final String loaiHoanCanh;
  final String moTaHoanCanh;
  final List<LichSuVanDong> lichSuVanDong;
  final String? tinhTrangHienTai;
  final int tongSoLanVanDong;

  ChiTietTreEmVanDong({
    required this.treEmID,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.tonGiao,
    required this.danToc,
    this.anh,
    required this.danhSachPhuHuynh,
    required this.hoanCanhID,
    required this.loaiHoanCanh,
    required this.moTaHoanCanh,
    required this.lichSuVanDong,
    this.tinhTrangHienTai,
    required this.tongSoLanVanDong,
  });

  factory ChiTietTreEmVanDong.fromJson(Map<String, dynamic> json) {
    return ChiTietTreEmVanDong(
      treEmID: json['treEmID'],
      hoTen: json['hoTen'],
      ngaySinh: DateTime.parse(json['ngaySinh']),
      gioiTinh: json['gioiTinh'],
      tonGiao: json['tonGiao'] ?? '',
      danToc: json['danToc'] ?? '',
      anh: json['anh'],
      danhSachPhuHuynh: (json['danhSachPhuHuynh'] as List)
          .map((e) => ThongTinPhuHuynh.fromJson(e))
          .toList(),
      hoanCanhID: json['hoanCanhID'] ?? 0, // ← THÊM
      loaiHoanCanh: json['loaiHoanCanh'] ?? '',
      moTaHoanCanh: json['moTaHoanCanh'] ?? '',
      lichSuVanDong: (json['lichSuVanDong'] as List)
          .map((e) => LichSuVanDong.fromJson(e))
          .toList(),
      tinhTrangHienTai: json['tinhTrangHienTai'],
      tongSoLanVanDong: json['tongSoLanVanDong'],
    );
  }
}

class LichSuHoTro {
  final int minhChungID;
  final String trangThaiPhat;
  final String? ghiChuTNV;
  final String? anhMinhChung;
  final DateTime ngayCap;

  LichSuHoTro({
    required this.minhChungID,
    required this.trangThaiPhat,
    this.ghiChuTNV,
    this.anhMinhChung,
    required this.ngayCap,
  });

  factory LichSuHoTro.fromJson(Map<String, dynamic> json) {
    return LichSuHoTro(
      minhChungID: json['minhChungID'],
      trangThaiPhat: json['trangThaiPhat'],
      ghiChuTNV: json['ghiChuTNV'],
      anhMinhChung: json['anhMinhChung'],
      ngayCap: DateTime.parse(json['ngayCap']),
    );
  }
}

class ChiTietTreEmHoTro {
  final int treEmID;
  final String hoTen;
  final DateTime ngaySinh;
  final String gioiTinh;
  final String tonGiao;
  final String danToc;
  final String? anh;
  final int hoTroID;
  final String loaiHoTro;
  final String moTaHoTro;
  final String trangThaiPhat;
  final DateTime? ngayHenLai;
  final List<ThongTinPhuHuynh> danhSachPhuHuynh;
  final List<LichSuHoTro> lichSuPhatHoTro;

  ChiTietTreEmHoTro({
    required this.treEmID,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.tonGiao,
    required this.danToc,
    this.anh,
    required this.hoTroID,
    required this.loaiHoTro,
    required this.moTaHoTro,
    required this.trangThaiPhat,
    this.ngayHenLai,
    required this.danhSachPhuHuynh,
    required this.lichSuPhatHoTro,
  });

  factory ChiTietTreEmHoTro.fromJson(Map<String, dynamic> json) {
    return ChiTietTreEmHoTro(
      treEmID: json['treEmID'],
      hoTen: json['hoTen'],
      ngaySinh: DateTime.parse(json['ngaySinh']),
      gioiTinh: json['gioiTinh'],
      tonGiao: json['tonGiao'] ?? '',
      danToc: json['danToc'] ?? '',
      anh: json['anh'],
      hoTroID: json['hoTroID'],
      loaiHoTro: json['loaiHoTro'],
      moTaHoTro: json['moTaHoTro'],
      trangThaiPhat: json['trangThaiPhat'],
      ngayHenLai: json['ngayHenLai'] != null
          ? DateTime.parse(json['ngayHenLai'])
          : null,
      danhSachPhuHuynh: (json['danhSachPhuHuynh'] as List)
          .map((e) => ThongTinPhuHuynh.fromJson(e))
          .toList(),
      lichSuPhatHoTro: (json['lichSuPhatHoTro'] as List)
          .map((e) => LichSuHoTro.fromJson(e))
          .toList(),
    );
  }
}