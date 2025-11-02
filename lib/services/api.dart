import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // - Nếu chạy trên Emulator Android: dùng 10.0.2.2
  // - Nếu chạy trên thiết bị thật: dùng IP máy tính (vd: 192.168.1.100)
  // static const String baseUrl = 'https://localhost:7001/api';
  // static const String baseUrl = 'http://10.0.2.2:5019/api';
  // static const String baseUrl = 'https://10.0.2.2:44362/api';
  // static const String baseUrl = 'http://10.0.2.2:5035/api';
  static const String baseUrl = 'http://192.168.1.146:5035/api';

  final _secureStorage = const FlutterSecureStorage();
  String? _authToken;


  Future<Map<String, dynamic>> checkApiStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/KhuPho');
      final httpClient = getHttpClient();

      final stopwatch = Stopwatch()..start();
      final request = await httpClient.getUrl(uri);
      // _headers.forEach((key, value) => request.headers.add(key, value));
      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));


      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      stopwatch.stop();

      httpClient.close();

      return {
        'connected': response.statusCode == 200,
        'statusCode': response.statusCode,
        'responseTime': stopwatch.elapsedMilliseconds,
        'message': response.statusCode == 200 ? 'Kết nối thành công' : 'Kết nối thất bại',
        'data': response.statusCode == 200 ? jsonDecode(responseBody) : null,
      };
    } catch (e) {
      return {
        'connected': false,
        'error': e.toString(),
        'message': 'Không thể kết nối tới server',
      };
    }
  }

  // Cho phép self-signed certificate
  static HttpClient getHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    return _authToken;
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.delete(key: 'auth_token');
  }

  // Map<String, String> get _headers {
  //   final headers = {'Content-Type': 'application/json; charset=UTF-8'};
  //   if (_authToken != null) {
  //     headers['Authorization'] = 'Bearer $_authToken';
  //   }
  //   return headers;
  // }

  Future<Map<String, String>> getHeaders() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<T> _get<T>(
      String endpoint,
      T Function(dynamic) parser,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 GET Request: $uri');
      final httpClient = getHttpClient();

      final request = await httpClient.getUrl(uri);
      // _headers.forEach((key, value) => request.headers.add(key, value));
      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));


      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('GET Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return parser(jsonDecode(responseBody));
      } else if (response.statusCode == 401) {
        await clearAuthToken();
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        print('GET Response Body: $responseBody');
        throw Exception('Lỗi ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) print('API GET Error: $e');
      rethrow;
    }
  }

  Future<T> _post<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser,
      ) async {
    try {
      print('Using Token: $_authToken');
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 POST Request: $uri');
      final httpClient = getHttpClient();

      final request = await httpClient.postUrl(uri);
      // _headers.forEach((key, value) => request.headers.add(key, value));
      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      request.add(utf8.encode(jsonEncode(data)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('POST Response Status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return parser(jsonDecode(responseBody));
      } else if (response.statusCode == 401) {
        await clearAuthToken();
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        print('POST Response Body: $responseBody');
        throw Exception('Lỗi ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) print('API POST Error: $e');
      rethrow;
    }
  }

  Future<T> _put<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 PUT Request: $uri');
      final httpClient = getHttpClient();

      final request = await httpClient.putUrl(uri);
      // _headers.forEach((key, value) => request.headers.add(key, value));
      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      request.add(utf8.encode(jsonEncode(data)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('PUT Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return parser(jsonDecode(responseBody));
      } else if (response.statusCode == 401) {
        await clearAuthToken();
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        print('PUT Response Body: $responseBody');
        throw Exception('Lỗi ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) print('API PUT Error: $e');
      rethrow;
    }
  }
  Future<T> _delete<T>(
      String endpoint,
      T Function(dynamic) parser,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 DELETE Request: $uri');
      final httpClient = getHttpClient();

      final request = await httpClient.deleteUrl(uri);
      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('DELETE Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Nếu API trả về JSON, parse bình thường
        return parser(jsonDecode(responseBody));
      } else if (response.statusCode == 204) {
        // Nếu API không trả nội dung (No Content)
        return parser({'success': true});
      } else if (response.statusCode == 401) {
        await clearAuthToken();
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        print('DELETE Response Body: $responseBody');
        throw Exception('Lỗi ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) print('API DELETE Error: $e');
      rethrow;
    }
  }

  Future<T> _uploadFile<T>(
      String endpoint,
      File file,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');

      // Tạo multipart request
      var request = http.MultipartRequest('POST', uri);

      // Thêm JWT token vào header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Thêm file vào request
      var multipartFile = await http.MultipartFile.fromPath(
        'file', // Tên field phải khớp với [FromForm] IFormFile file trong API
        file.path,
      );
      request.files.add(multipartFile);

      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Xử lý response
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return fromJson(jsonResponse);
      } else {
        var errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  /// Gọi API GET
  Future<T> Get<T>(
      String endpoint,
      T Function(dynamic) parser,
      ) =>
      _get(endpoint, parser);

  /// Gọi API POST
  Future<T> Post<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser,
      ) =>
      _post(endpoint, data, parser);

  /// Gọi API PUT
  Future<T> Put<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser,
      ) =>
      _put(endpoint, data, parser);

  /// Gọi API DELETE
  Future<T> Delete<T>(
      String endpoint,
      T Function(dynamic) parser,
      ) =>
      _delete(endpoint, parser);

  /// Gọi API UPLOADFILE
  Future<T> UploadFile<T>(
      String endpoint,
      File file,
      T Function(Map<String, dynamic>) fromJson,
      ) =>
      _uploadFile(endpoint, file, fromJson);
}