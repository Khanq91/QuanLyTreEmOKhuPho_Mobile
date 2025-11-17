import 'package:flutter/material.dart';

class ThongBaoDto {
  final int thongBaoId;
  final String noiDung;
  final DateTime ngayThongBao;
  final bool daDoc;
  final int? suKienId;
  final String? tenSuKien;
  final String loaiThongBao; // SuKien, VanDong, HoTro, PhanCong, ThongTin
  final String mucDoUuTien; // URGENT, IMPORTANT, INFO

  ThongBaoDto({
    required this.thongBaoId,
    required this.noiDung,
    required this.ngayThongBao,
    required this.daDoc,
    this.suKienId,
    this.tenSuKien,
    required this.loaiThongBao,
    required this.mucDoUuTien,
  });

  factory ThongBaoDto.fromJson(Map<String, dynamic> json) {
    return ThongBaoDto(
      thongBaoId: json['thongBaoId'] ?? 0,
      noiDung: json['noiDung'] ?? '',
      ngayThongBao: json['ngayThongBao'] != null
          ? DateTime.parse(json['ngayThongBao'])
          : DateTime.now(),
      daDoc: json['daDoc'] ?? false,
      suKienId: json['suKienId'],
      tenSuKien: json['tenSuKien'],
      loaiThongBao: json['loaiThongBao'] ?? 'ThongTin',
      mucDoUuTien: json['mucDoUuTien'] ?? 'INFO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thongBaoId': thongBaoId,
      'noiDung': noiDung,
      'ngayThongBao': ngayThongBao.toIso8601String(),
      'daDoc': daDoc,
      'suKienId': suKienId,
      'tenSuKien': tenSuKien,
      'loaiThongBao': loaiThongBao,
      'mucDoUuTien': mucDoUuTien,
    };
  }

  ThongBaoDto copyWith({
    int? thongBaoId,
    String? noiDung,
    DateTime? ngayThongBao,
    bool? daDoc,
    int? suKienId,
    String? tenSuKien,
    String? loaiThongBao,
    String? mucDoUuTien,
  }) {
    return ThongBaoDto(
      thongBaoId: thongBaoId ?? this.thongBaoId,
      noiDung: noiDung ?? this.noiDung,
      ngayThongBao: ngayThongBao ?? this.ngayThongBao,
      daDoc: daDoc ?? this.daDoc,
      suKienId: suKienId ?? this.suKienId,
      tenSuKien: tenSuKien ?? this.tenSuKien,
      loaiThongBao: loaiThongBao ?? this.loaiThongBao,
      mucDoUuTien: mucDoUuTien ?? this.mucDoUuTien,
    );
  }

  /// Lấy icon theo loại thông báo
  IconData get icon {
    switch (loaiThongBao) {
      case 'SuKien':
        return Icons.event;
      case 'VanDong':
        return Icons.directions_run;
      case 'HoTro':
        return Icons.card_giftcard;
      case 'PhanCong':
        return Icons.assignment;
      case 'KhanCap':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  /// Lấy màu icon theo loại thông báo
  Color get iconColor {
    switch (loaiThongBao) {
      case 'SuKien':
        return const Color(0xFF2196F3); // Blue
      case 'VanDong':
        return const Color(0xFFFF9800); // Orange
      case 'HoTro':
        return const Color(0xFF4CAF50); // Green
      case 'PhanCong':
        return const Color(0xFF9C27B0); // Purple
      case 'KhanCap':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  /// Lấy màu nền icon theo loại thông báo
  Color get iconBackgroundColor {
    return iconColor.withOpacity(0.1);
  }

  /// Lấy màu theo mức độ ưu tiên
  Color get priorityColor {
    switch (mucDoUuTien) {
      case 'URGENT':
        return const Color(0xFFF44336); // Red
      case 'IMPORTANT':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }

  /// Format thời gian hiển thị
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(ngayThongBao);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}