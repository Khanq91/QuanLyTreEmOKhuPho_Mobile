// 1. Model cho Carousel
class TreEmBasicInfo {
  final int treEmID;
  final String hoTen;
  final String ngaySinh;
  final String gioiTinh;
  final String? anh;
  final String tenTruong;
  final String capHoc;

  TreEmBasicInfo({
    required this.treEmID,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    this.anh,
    required this.tenTruong,
    required this.capHoc,
  });

  factory TreEmBasicInfo.fromJson(Map<String, dynamic> json) {
    return TreEmBasicInfo(
      treEmID: json['treEmID'] ?? 0,
      hoTen: json['hoTen'] ?? '',
      ngaySinh: json['ngaySinh'] ?? '',
      gioiTinh: json['gioiTinh'] ?? '',
      anh: json['anh'],
      tenTruong: json['tenTruong'] ?? '',
      capHoc: json['capHoc'] ?? '',
    );
  }
}

class DanhSachConResponse {
  final List<TreEmBasicInfo> danhSachCon;

  DanhSachConResponse({required this.danhSachCon});

  factory DanhSachConResponse.fromJson(Map<String, dynamic> json) {
    var list = json['danhSachCon'] as List;
    List<TreEmBasicInfo> children = list.map((i) => TreEmBasicInfo.fromJson(i)).toList();
    return DanhSachConResponse(danhSachCon: children);
  }
}

// 2. Model cho Phiếu học tập
class PhieuHocTapInfo {
  final int phieuHocTapID;
  final double diemTrungBinh;
  final String xepLoai;
  final String hanhKiem;
  final String nhanXet;
  final String ngayCapNhat;
  final String tenLop;
  final String tenTruong;

  PhieuHocTapInfo({
    required this.phieuHocTapID,
    required this.diemTrungBinh,
    required this.xepLoai,
    required this.hanhKiem,
    required this.nhanXet,
    required this.ngayCapNhat,
    required this.tenLop,
    required this.tenTruong,
  });

  factory PhieuHocTapInfo.fromJson(Map<String, dynamic> json) {
    return PhieuHocTapInfo(
      phieuHocTapID: json['phieuHocTapID'] ?? 0,
      diemTrungBinh: (json['diemTrungBinh'] ?? 0.0).toDouble(),
      xepLoai: json['xepLoai'] ?? '',
      hanhKiem: json['hanhKiem'] ?? '',
      nhanXet: json['nhanXet'] ?? '',
      ngayCapNhat: json['ngayCapNhat'] ?? '',
      tenLop: json['tenLop'] ?? '',
      tenTruong: json['tenTruong'] ?? '',
    );
  }
}

class TabHocTapResponse {
  final List<PhieuHocTapInfo> danhSachPhieuHocTap;

  TabHocTapResponse({required this.danhSachPhieuHocTap});

  factory TabHocTapResponse.fromJson(Map<String, dynamic> json) {
    var list = json['danhSachPhieuHocTap'] as List;
    List<PhieuHocTapInfo> phieuList = list.map((i) => PhieuHocTapInfo.fromJson(i)).toList();
    return TabHocTapResponse(danhSachPhieuHocTap: phieuList);
  }
}

// 3. Model cho Hỗ trợ
class MinhChungInfo {
  final int minhChungID;
  final String loaiMinhChung;
  final String filePath;
  final String ngayCap;

  MinhChungInfo({
    required this.minhChungID,
    required this.loaiMinhChung,
    required this.filePath,
    required this.ngayCap,
  });

  factory MinhChungInfo.fromJson(Map<String, dynamic> json) {
    return MinhChungInfo(
      minhChungID: json['minhChungID'] ?? 0,
      loaiMinhChung: json['loaiMinhChung'] ?? '',
      filePath: json['filePath'] ?? '',
      ngayCap: json['ngayCap'] ?? '',
    );
  }
}

class HoTroPhucLoiInfo {
  final int hoTroID;
  final String loaiHoTro;
  final String moTa;
  final String ngayCap;
  final String nguoiChiuTrachNhiem;
  final List<MinhChungInfo> danhSachMinhChung;

  HoTroPhucLoiInfo({
    required this.hoTroID,
    required this.loaiHoTro,
    required this.moTa,
    required this.ngayCap,
    required this.nguoiChiuTrachNhiem,
    required this.danhSachMinhChung,
  });

  factory HoTroPhucLoiInfo.fromJson(Map<String, dynamic> json) {
    var minhChungList = json['danhSachMinhChung'] as List;
    List<MinhChungInfo> minhChungs = minhChungList.map((i) => MinhChungInfo.fromJson(i)).toList();

    return HoTroPhucLoiInfo(
      hoTroID: json['hoTroID'] ?? 0,
      loaiHoTro: json['loaiHoTro'] ?? '',
      moTa: json['moTa'] ?? '',
      ngayCap: json['ngayCap'] ?? '',
      nguoiChiuTrachNhiem: json['nguoiChiuTrachNhiem'] ?? '',
      danhSachMinhChung: minhChungs,
    );
  }
}

class UngHoInfo {
  final int ungHoID;
  final double soTien;
  final String loaiUngHo;
  final String ngayUngHo;
  final String ghiChu;
  final String tenManhThuongQuan;
  final String loaiManhThuongQuan;

  UngHoInfo({
    required this.ungHoID,
    required this.soTien,
    required this.loaiUngHo,
    required this.ngayUngHo,
    required this.ghiChu,
    required this.tenManhThuongQuan,
    required this.loaiManhThuongQuan,
  });

  factory UngHoInfo.fromJson(Map<String, dynamic> json) {
    return UngHoInfo(
      ungHoID: json['ungHoID'] ?? 0,
      soTien: (json['soTien'] ?? 0.0).toDouble(),
      loaiUngHo: json['loaiUngHo'] ?? '',
      ngayUngHo: json['ngayUngHo'] ?? '',
      ghiChu: json['ghiChu'] ?? '',
      tenManhThuongQuan: json['tenManhThuongQuan'] ?? '',
      loaiManhThuongQuan: json['loaiManhThuongQuan'] ?? '',
    );
  }
}

class TabHoTroResponse {
  final List<HoTroPhucLoiInfo> danhSachHoTro;
  final List<UngHoInfo> danhSachUngHo;

  TabHoTroResponse({
    required this.danhSachHoTro,
    required this.danhSachUngHo,
  });

  factory TabHoTroResponse.fromJson(Map<String, dynamic> json) {
    var hoTroList = json['danhSachHoTro'] as List;
    var ungHoList = json['danhSachUngHo'] as List;

    return TabHoTroResponse(
      danhSachHoTro: hoTroList.map((i) => HoTroPhucLoiInfo.fromJson(i)).toList(),
      danhSachUngHo: ungHoList.map((i) => UngHoInfo.fromJson(i)).toList(),
    );
  }
}
