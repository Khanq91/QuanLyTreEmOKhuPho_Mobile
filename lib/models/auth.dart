class ForgotPasswordResponse {
  final bool success;
  final String message;
  final ForgotPasswordData? data;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ForgotPasswordData.fromJson(json['data'])
          : null,
    );
  }
}

class ForgotPasswordData {
  final String sdt;
  final String hoTen;
  final String matKhauMoi;
  final String vaiTro;

  ForgotPasswordData({
    required this.sdt,
    required this.hoTen,
    required this.matKhauMoi,
    required this.vaiTro,
  });

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      sdt: json['sdt'] ?? '',
      hoTen: json['hoTen'] ?? '',
      matKhauMoi: json['matKhauMoi'] ?? '',
      vaiTro: json['vaiTro'] ?? '',
    );
  }
}