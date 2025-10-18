class User {
  final int userId;
  final String email;
  final String hoTen;
  final String vaiTro;

  User({
    required this.userId,
    required this.email,
    required this.hoTen,
    required this.vaiTro,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      email: map['email'],
      hoTen: map['hoTen'],
      vaiTro: map['vaiTro'],
    );
  }
}