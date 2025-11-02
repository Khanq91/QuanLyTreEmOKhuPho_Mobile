class ThongBaoInfo {
  final int thongBaoID;
  final String noiDung;
  final String ngayThongBao;
  final bool daDoc;
  final int? suKienID;
  final String? tenSuKien;

  ThongBaoInfo({
    required this.thongBaoID,
    required this.noiDung,
    required this.ngayThongBao,
    required this.daDoc,
    this.suKienID,
    this.tenSuKien,
  });

  factory ThongBaoInfo.fromJson(Map<String, dynamic> json) {
    return ThongBaoInfo(
      thongBaoID: json['thongBaoID'] ?? 0,
      noiDung: json['noiDung'] ?? '',
      ngayThongBao: json['ngayThongBao'] ?? '',
      daDoc: json['daDoc'] ?? false,
      suKienID: json['suKienID'],
      tenSuKien: json['tenSuKien'],
    );
  }
}

class TabThongBaoResponse {
  final int soLuongChuaDoc;
  final List<ThongBaoInfo> danhSachThongBao;

  TabThongBaoResponse({
    required this.soLuongChuaDoc,
    required this.danhSachThongBao,
  });

  factory TabThongBaoResponse.fromJson(Map<String, dynamic> json) {
    var list = json['danhSachThongBao'] as List;
    List<ThongBaoInfo> thongBaoList = list.map((i) => ThongBaoInfo.fromJson(i)).toList();

    return TabThongBaoResponse(
      soLuongChuaDoc: json['soLuongChuaDoc'] ?? 0,
      danhSachThongBao: thongBaoList,
    );
  }
}