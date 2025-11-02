class LoginResponse {
  final String token;
  final String hoTen;
  final String vaiTro;
  final int userId;

  LoginResponse({
    required this.token,
    required this.hoTen,
    required this.vaiTro,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      hoTen: json['hoTen'] ?? '',
      vaiTro: json['vaiTro'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }
}
