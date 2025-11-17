class DashboardPhuHuynh {
  final List<TreEmDropdown> danhSachCon;
  final int treEmMacDinhId;
  final ThongTinHocTap? thongTinHocTap;
  final List<HoTroInfo> hoTroDaNhan;
  final List<SuKienInfo> suKienSapToi;
  final List<ThongBaoInfoDashBoard> thongBaoChuaDoc;
  final int soThongBaoChuaDoc;

  DashboardPhuHuynh({
    required this.danhSachCon,
    required this.treEmMacDinhId,
    this.thongTinHocTap,
    required this.hoTroDaNhan,
    required this.suKienSapToi,
    required this.thongBaoChuaDoc,
    required this.soThongBaoChuaDoc,
  });

  factory DashboardPhuHuynh.fromJson(Map<String, dynamic> json) {
    return DashboardPhuHuynh(
      danhSachCon: (json['danhSachCon'] as List<dynamic>?)
          ?.map((e) => TreEmDropdown.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      treEmMacDinhId: json['treEmMacDinhId'] ?? 0,
      thongTinHocTap: json['thongTinHocTap'] != null
          ? ThongTinHocTap.fromJson(json['thongTinHocTap'] as Map<String, dynamic>)
          : null,
      hoTroDaNhan: (json['hoTroDaNhan'] as List<dynamic>?)
          ?.map((e) => HoTroInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      suKienSapToi: (json['suKienSapToi'] as List<dynamic>?)
          ?.map((e) => SuKienInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      thongBaoChuaDoc: (json['thongBaoChuaDoc'] as List<dynamic>?)
          ?.map((e) => ThongBaoInfoDashBoard.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      soThongBaoChuaDoc: json['soThongBaoChuaDoc'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'danhSachCon': danhSachCon.map((e) => e.toJson()).toList(),
      'treEmMacDinhId': treEmMacDinhId,
      'thongTinHocTap': thongTinHocTap?.toJson(),
      'hoTroDaNhan': hoTroDaNhan.map((e) => e.toJson()).toList(),
      'suKienSapToi': suKienSapToi.map((e) => e.toJson()).toList(),
      'thongBaoChuaDoc': thongBaoChuaDoc.map((e) => e.toJson()).toList(),
      'soThongBaoChuaDoc': soThongBaoChuaDoc,
    };
  }
}

// ============================================
// tre_em_dropdown.dart
// ============================================

class TreEmDropdown {
  final int treEmID;
  final String hoTen;
  final String? anh;
  final DateTime ngaySinh;
  final int tuoi;

  TreEmDropdown({
    required this.treEmID,
    required this.hoTen,
    this.anh,
    required this.ngaySinh,
    required this.tuoi,
  });

  factory TreEmDropdown.fromJson(Map<String, dynamic> json) {
    return TreEmDropdown(
      treEmID: json['treEmID'] ?? 0,
      hoTen: json['hoTen'] ?? '',
      anh: json['anh'],
      ngaySinh: json['ngaySinh'] != null
          ? DateTime.parse(json['ngaySinh'])
          : DateTime.now(),
      tuoi: json['tuoi'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treEmID': treEmID,
      'hoTen': hoTen,
      'anh': anh,
      'ngaySinh': ngaySinh.toIso8601String(),
      'tuoi': tuoi,
    };
  }
}

// ============================================
// thong_tin_hoc_tap.dart
// ============================================

class ThongTinHocTap {
  final int phieuHocTapID;
  final String tenTreEm;
  final String tenTruong;
  final String tenLop;
  final double diemTrungBinh;
  final String xepLoai;
  final String hanhKiem;
  final String? ghiChu;
  final DateTime ngayCapNhat;

  ThongTinHocTap({
    required this.phieuHocTapID,
    required this.tenTreEm,
    required this.tenTruong,
    required this.tenLop,
    required this.diemTrungBinh,
    required this.xepLoai,
    required this.hanhKiem,
    this.ghiChu,
    required this.ngayCapNhat,
  });

  factory ThongTinHocTap.fromJson(Map<String, dynamic> json) {
    return ThongTinHocTap(
      phieuHocTapID: json['phieuHocTapID'] ?? 0,
      tenTreEm: json['tenTreEm'] ?? '',
      tenTruong: json['tenTruong'] ?? '',
      tenLop: json['tenLop'] ?? '',
      diemTrungBinh: (json['diemTrungBinh'] ?? 0).toDouble(),
      xepLoai: json['xepLoai'] ?? '',
      hanhKiem: json['hanhKiem'] ?? '',
      ghiChu: json['ghiChu'],
      ngayCapNhat: json['namHoc'] != null
          ? DateTime.parse(json['namHoc'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phieuHocTapID': phieuHocTapID,
      'tenTreEm': tenTreEm,
      'tenTruong': tenTruong,
      'tenLop': tenLop,
      'diemTrungBinh': diemTrungBinh,
      'xepLoai': xepLoai,
      'hanhKiem': hanhKiem,
      'ghiChu': ghiChu,
      'namHoc': ngayCapNhat.toIso8601String(),
    };
  }

  // Helper để hiển thị màu sắc theo xếp loại
  String get xepLoaiColor {
    switch (xepLoai.toLowerCase()) {
      case 'xuất sắc':
        return '#FFD700'; // Gold
      case 'giỏi':
        return '#4CAF50'; // Green
      case 'khá':
        return '#2196F3'; // Blue
      case 'trung bình':
        return '#FF9800'; // Orange
      case 'yếu':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }
}

// ============================================
// ho_tro_info.dart
// ============================================

class HoTroInfo {
  final int hoTroID;
  final String loaiHoTro;
  final String? moTa;
  final DateTime ngayCap;
  final String nguoiChiuTrachNhiemHoTro;

  HoTroInfo({
    required this.hoTroID,
    required this.loaiHoTro,
    this.moTa,
    required this.ngayCap,
    required this.nguoiChiuTrachNhiemHoTro,
  });

  factory HoTroInfo.fromJson(Map<String, dynamic> json) {
    return HoTroInfo(
      hoTroID: json['hoTroID'] ?? 0,
      loaiHoTro: json['loaiHoTro'] ?? '',
      moTa: json['moTa'],
      ngayCap: json['ngayCap'] != null
          ? DateTime.parse(json['ngayCap'])
          : DateTime.now(),
      nguoiChiuTrachNhiemHoTro: json['nguoiChiuTrachNhiemHoTro'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hoTroID': hoTroID,
      'loaiHoTro': loaiHoTro,
      'moTa': moTa,
      'ngayCap': ngayCap.toIso8601String(),
      'nguoiChiuTrachNhiemHoTro': nguoiChiuTrachNhiemHoTro,
    };
  }

  // Helper để format ngày
  String get ngayCapFormatted {
    return '${ngayCap.day.toString().padLeft(2, '0')}/${ngayCap.month.toString().padLeft(2, '0')}/${ngayCap.year}';
  }
}

// ============================================
// su_kien_info.dart
// ============================================

class SuKienInfo {
  final int suKienID;
  final String tenSuKien;
  final String? moTa;
  final String diaDiem;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final String tenKhuPho;

  SuKienInfo({
    required this.suKienID,
    required this.tenSuKien,
    this.moTa,
    required this.diaDiem,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.tenKhuPho,
  });

  factory SuKienInfo.fromJson(Map<String, dynamic> json) {
    return SuKienInfo(
      suKienID: json['suKienID'] ?? 0,
      tenSuKien: json['tenSuKien'] ?? '',
      moTa: json['moTa'],
      diaDiem: json['diaDiem'] ?? '',
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.parse(json['ngayBatDau'])
          : DateTime.now(),
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.parse(json['ngayKetThuc'])
          : DateTime.now(),
      tenKhuPho: json['tenKhuPho'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suKienID': suKienID,
      'tenSuKien': tenSuKien,
      'moTa': moTa,
      'diaDiem': diaDiem,
      'ngayBatDau': ngayBatDau.toIso8601String(),
      'ngayKetThuc': ngayKetThuc.toIso8601String(),
      'tenKhuPho': tenKhuPho,
    };
  }

  // Helper để tính số ngày còn lại
  int get soNgayConLai {
    final now = DateTime.now();
    final difference = ngayBatDau.difference(now);
    return difference.inDays;
  }

  // Helper để format ngày
  String get ngayBatDauFormatted {
    return '${ngayBatDau.day.toString().padLeft(2, '0')}/${ngayBatDau.month.toString().padLeft(2, '0')}/${ngayBatDau.year}';
  }

  String get ngayKetThucFormatted {
    return '${ngayKetThuc.day.toString().padLeft(2, '0')}/${ngayKetThuc.month.toString().padLeft(2, '0')}/${ngayKetThuc.year}';
  }

  // Helper để kiểm tra sự kiện diễn ra trong ngày
  bool get isDienRaHomNay {
    final now = DateTime.now();
    return ngayBatDau.day == now.day &&
        ngayBatDau.month == now.month &&
        ngayBatDau.year == now.year;
  }
}

// ============================================
// thong_bao_info.dart
// ============================================

class ThongBaoInfoDashBoard {
  final int thongBaoID;
  final String noiDung;
  final DateTime ngayThongBao;
  final String? tenSuKien;

  ThongBaoInfoDashBoard({
    required this.thongBaoID,
    required this.noiDung,
    required this.ngayThongBao,
    this.tenSuKien,
  });

  factory ThongBaoInfoDashBoard.fromJson(Map<String, dynamic> json) {
    return ThongBaoInfoDashBoard(
      thongBaoID: json['thongBaoID'] ?? 0,
      noiDung: json['noiDung'] ?? '',
      ngayThongBao: json['ngayThongBao'] != null
          ? DateTime.parse(json['ngayThongBao'])
          : DateTime.now(),
      tenSuKien: json['tenSuKien'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thongBaoID': thongBaoID,
      'noiDung': noiDung,
      'ngayThongBao': ngayThongBao.toIso8601String(),
      'tenSuKien': tenSuKien,
    };
  }

  // Helper để format thời gian tương đối
  String get thoiGianTuongDoi {
    final now = DateTime.now();
    final difference = now.difference(ngayThongBao);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${ngayThongBao.day}/${ngayThongBao.month}/${ngayThongBao.year}';
    }
  }
}