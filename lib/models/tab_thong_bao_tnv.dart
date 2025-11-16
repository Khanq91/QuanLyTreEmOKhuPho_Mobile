

class ThongBaoDto {
  final int thongBaoId;
  final int? suKienId;
  final String noiDung;
  final DateTime ngayThongBao;
  final bool daDoc;
  final String? tenSuKien;
  final DateTime? ngayBatDauSuKien;

  ThongBaoDto({
    required this.thongBaoId,
    this.suKienId,
    required this.noiDung,
    required this.ngayThongBao,
    required this.daDoc,
    this.tenSuKien,
    this.ngayBatDauSuKien,
  });

  factory ThongBaoDto.fromJson(Map<String, dynamic> json) {
    return ThongBaoDto(
      thongBaoId: json['thongBaoId'] ?? 0,
      suKienId: json['suKienId'],
      noiDung: json['noiDung'] ?? '',
      ngayThongBao: DateTime.parse(json['ngayThongBao']),
      daDoc: json['daDoc'] ?? false,
      tenSuKien: json['tenSuKien'],
      ngayBatDauSuKien: json['ngayBatDauSuKien'] != null
          ? DateTime.parse(json['ngayBatDauSuKien'])
          : null,
    );
  }

  ThongBaoDto copyWith({bool? daDoc}) {
    return ThongBaoDto(
      thongBaoId: thongBaoId,
      suKienId: suKienId,
      noiDung: noiDung,
      ngayThongBao: ngayThongBao,
      daDoc: daDoc ?? this.daDoc,
      tenSuKien: tenSuKien,
      ngayBatDauSuKien: ngayBatDauSuKien,
    );
  }
}

class DanhDauDocRequest {
  final int thongBaoId;

  DanhDauDocRequest({required this.thongBaoId});

  Map<String, dynamic> toJson() => {'thongBaoId': thongBaoId};
}

class DanhDauTatCaDocRequest {
  DanhDauTatCaDocRequest();

  Map<String, dynamic> toJson() => {};
}