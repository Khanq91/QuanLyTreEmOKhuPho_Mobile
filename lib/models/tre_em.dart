class Child {
  final int treEmId;
  final String hoTen;
  final String ngaySinh;
  final String gioiTinh;
  final String truong;
  final String lop;
  final String avatar;

  Child({
    required this.treEmId,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.truong,
    required this.lop,
    required this.avatar,
  });

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      treEmId: map['treEmId'],
      hoTen: map['hoTen'],
      ngaySinh: map['ngaySinh'],
      gioiTinh: map['gioiTinh'],
      truong: map['truong'],
      lop: map['lop'],
      avatar: map['avatar'],
    );
  }
}