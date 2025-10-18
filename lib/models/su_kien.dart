class Event {
  final int suKienId;
  final String tenSuKien;
  final String moTa;
  final String diaDiem;
  final String ngayBatDau;
  final String ngayKetThuc;
  final String trangThai;

  Event({
    required this.suKienId,
    required this.tenSuKien,
    required this.moTa,
    required this.diaDiem,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.trangThai,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      suKienId: map['suKienId'],
      tenSuKien: map['tenSuKien'],
      moTa: map['moTa'],
      diaDiem: map['diaDiem'],
      ngayBatDau: map['ngayBatDau'],
      ngayKetThuc: map['ngayKetThuc'],
      trangThai: map['trangThai'],
    );
  }
}