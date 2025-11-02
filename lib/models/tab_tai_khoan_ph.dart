class ThongTinTaiKhoanResponse {
  final int userID;
  final String hoTen;
  final String email;
  final String sdt;
  final String anh;

  ThongTinTaiKhoanResponse({
    required this.userID,
    required this.hoTen,
    required this.email,
    required this.sdt,
    required this.anh,
  });

  factory ThongTinTaiKhoanResponse.fromJson(Map<String, dynamic> json) {
    return ThongTinTaiKhoanResponse(
      userID: json['userID'] ?? 0,
      hoTen: json['hoTen'] ?? '',
      email: json['email'] ?? '',
      sdt: json['sdt'] ?? '',
      anh: json['anh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'hoTen': hoTen,
      'email': email,
      'sdt': sdt,
      'anh': anh,
    };
  }
}

class DanhSachPhuHuynhResponse {
  final List<PhuHuynhVoiMoiQuanHe> danhSachPhuHuynh;
  DanhSachPhuHuynhResponse({required this.danhSachPhuHuynh});
  factory DanhSachPhuHuynhResponse.fromJson(Map<String, dynamic> json) {
    return DanhSachPhuHuynhResponse(
      danhSachPhuHuynh: (json['danhSachPhuHuynh'] as List)
          .map((item) => PhuHuynhVoiMoiQuanHe.fromJson(item))
          .toList(),
    );
  }
}
class PhuHuynhVoiMoiQuanHe {
  final int phuHuynhID;
  final String hoTen;
  final String sdt;
  final String diaChi;
  final String ngheNghiep;
  final String ngaySinh;
  final String tonGiao;
  final String danToc;
  final String quocTich;
  final String anh;
  final List<MoiQuanHeVoiTreEm> danhSachMoiQuanHe;
  PhuHuynhVoiMoiQuanHe({
    required this.phuHuynhID,
    required this.hoTen,
    required this.sdt,
    required this.diaChi,
    required this.ngheNghiep,
    required this.ngaySinh,
    required this.tonGiao,
    required this.danToc,
    required this.quocTich,
    required this.anh,
    required this.danhSachMoiQuanHe,
  });
  factory PhuHuynhVoiMoiQuanHe.fromJson(Map<String, dynamic> json) {
    return PhuHuynhVoiMoiQuanHe(
      phuHuynhID: json['phuHuynhID'] ?? 0,
      hoTen: json['hoTen'] ?? '',
      sdt: json['sdt'] ?? '',
      diaChi: json['diaChi'] ?? '',
      ngheNghiep: json['ngheNghiep'] ?? '',
      ngaySinh: json['ngaySinh'] ?? '',
      tonGiao: json['tonGiao'] ?? '',
      danToc: json['danToc'] ?? '',
      quocTich: json['quocTich'] ?? '',
      anh: json['anh'] ?? '',
      danhSachMoiQuanHe: (json['danhSachMoiQuanHe'] as List?)
          ?.map((item) => MoiQuanHeVoiTreEm.fromJson(item))
          .toList() ??
          [],
    );
  }
}
class MoiQuanHeVoiTreEm {
  final int treEmID;
  final String tenTreEm;
  final String moiQuanHe;
  final String anh;
  MoiQuanHeVoiTreEm({
    required this.treEmID,
    required this.tenTreEm,
    required this.moiQuanHe,
    required this.anh,
  });
  factory MoiQuanHeVoiTreEm.fromJson(Map<String, dynamic> json) {
    return MoiQuanHeVoiTreEm(
      treEmID: json['treEmID'] ?? 0,
      tenTreEm: json['tenTreEm'] ?? '',
      moiQuanHe: json['moiQuanHe'] ?? '',
      anh: json['anh'] ?? '',
    );
  }
}
class ThongTinTreEmChiTietResponse {
  final int treEmID;
  final String hoTen;
  final String ngaySinh;
  final String gioiTinh;
  final String tonGiao;
  final String danToc;
  final String quocTich;
  final String anh;
  final int? truongID;
  final String tenTruong;
  final String capHoc;
  final int? lopID;
  final String tenLop;
  ThongTinTreEmChiTietResponse({
    required this.treEmID,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.tonGiao,
    required this.danToc,
    required this.quocTich,
    required this.anh,
    this.truongID,
    required this.tenTruong,
    required this.capHoc,
    this.lopID,
    required this.tenLop,
  });
  factory ThongTinTreEmChiTietResponse.fromJson(Map<String, dynamic> json) {
    return ThongTinTreEmChiTietResponse(
      treEmID: json['treEmID'] ?? 0,
      hoTen: json['hoTen'] ?? '',
      ngaySinh: json['ngaySinh'] ?? '',
      gioiTinh: json['gioiTinh'] ?? '',
      tonGiao: json['tonGiao'] ?? '',
      danToc: json['danToc'] ?? '',
      quocTich: json['quocTich'] ?? '',
      anh: json['anh'] ?? '',
      truongID: json['truongID'],
      tenTruong: json['tenTruong'] ?? '',
      capHoc: json['capHoc'] ?? '',
      lopID: json['lopID'],
      tenLop: json['tenLop'] ?? '',
    );
  }
}
