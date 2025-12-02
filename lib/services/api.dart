import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static final String baseUrl = "${dotenv.env['BASE_URL']!}/api";

  final _secureStorage = const FlutterSecureStorage();
  String? _authToken;
  String? _authVaiTro;

  // ==================== TIMEOUT CONFIGURATION ====================
  /// Timeout cho các request thông thường (10 giây)
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Timeout cho check API status (5 giây)
  static const Duration checkStatusTimeout = Duration(seconds: 5);

  /// Timeout cho upload file (30 giây)
  static const Duration uploadTimeout = Duration(seconds: 30);

  // ==================== CHECK API STATUS WITH TIMEOUT ====================
  Future<Map<String, dynamic>> checkApiStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/KhuPho');
      final httpClient = getHttpClient();

      final stopwatch = Stopwatch()..start();

      // Tạo request với timeout
      final request = await httpClient
          .getUrl(uri)
          .timeout(checkStatusTimeout);

      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      // Thực hiện request với timeout
      final response = await request
          .close()
          .timeout(checkStatusTimeout);

      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(checkStatusTimeout);

      stopwatch.stop();
      httpClient.close();

      final isSuccess = response.statusCode == 200;

      return {
        'connected': isSuccess,
        'statusCode': response.statusCode,
        'responseTime': stopwatch.elapsedMilliseconds,
        'message': isSuccess
            ? 'Kết nối thành công (${stopwatch.elapsedMilliseconds}ms)'
            : 'Server trả về lỗi ${response.statusCode}',
        'data': isSuccess ? jsonDecode(responseBody) : null,
        'errorType': isSuccess ? null : 'SERVER_ERROR',
      };
    } on TimeoutException catch (e) {
      return {
        'connected': false,
        'error': 'Timeout: ${e.message ?? "Quá thời gian chờ"}',
        'message': 'Kết nối quá chậm (timeout ${checkStatusTimeout.inSeconds}s)',
        'errorType': 'TIMEOUT',
      };
    } on SocketException catch (e) {
      return {
        'connected': false,
        'error': 'Socket: ${e.message}',
        'message': 'Không thể kết nối - Kiểm tra mạng hoặc địa chỉ server',
        'errorType': 'NETWORK',
      };
    } on HandshakeException catch (e) {
      return {
        'connected': false,
        'error': 'SSL: ${e.message}',
        'message': 'Lỗi bảo mật SSL - Kiểm tra cấu hình HTTPS',
        'errorType': 'SSL',
      };
    } on FormatException catch (e) {
      return {
        'connected': false,
        'error': 'Format: ${e.message}',
        'message': 'Dữ liệu phản hồi không hợp lệ',
        'errorType': 'FORMAT',
      };
    } catch (e) {
      return {
        'connected': false,
        'error': e.toString(),
        'message': 'Lỗi không xác định khi kết nối',
        'errorType': 'UNKNOWN',
      };
    }
  }

  // ==================== HTTP CLIENT WITH TIMEOUT ====================
  static HttpClient getHttpClient() {
    final client = HttpClient();

    // Cho phép self-signed certificate
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    // Set connection timeout
    client.connectionTimeout = defaultTimeout;

    // Set idle timeout
    client.idleTimeout = const Duration(seconds: 15);

    return client;
  }

  // ==================== AUTH TOKEN METHODS ====================
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    return _authToken;
  }

  Future<void> setVaiTro(String vaiTro) async {
    _authVaiTro = vaiTro;
    await _secureStorage.write(key: 'auth_vaitro', value: vaiTro);
  }

  Future<String?> getsetVaiTro() async {
    _authVaiTro ??= await _secureStorage.read(key: 'auth_vaitro');
    return _authVaiTro;
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    _authVaiTro = null;
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'auth_vaitro');
  }

  Future<Map<String, String>> getHeaders() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==================== GET REQUEST WITH TIMEOUT ====================
  Future<T> _get<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Map<String, dynamic>? queryParams,
        Duration? timeout,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      print('🌐 GET Request: $uri');

      final httpClient = getHttpClient();
      final request = await httpClient
          .getUrl(uri)
          .timeout(timeout ?? defaultTimeout);

      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      final response = await request
          .close()
          .timeout(timeout ?? defaultTimeout);

      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout ?? defaultTimeout);

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
    } on TimeoutException {
      throw Exception('Kết nối quá chậm, vui lòng thử lại');
    } on SocketException catch (e) {
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      if (kDebugMode) print('API GET Error: $e');
      rethrow;
    }
  }

  // ==================== POST REQUEST WITH TIMEOUT ====================
  Future<T> _post<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser, {
        Duration? timeout,
      }) async {
    try {
      print('Using Token: $_authToken');
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 POST Request: $uri');

      final httpClient = getHttpClient();
      final request = await httpClient
          .postUrl(uri)
          .timeout(timeout ?? defaultTimeout);

      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      request.add(utf8.encode(jsonEncode(data)));

      final response = await request
          .close()
          .timeout(timeout ?? defaultTimeout);

      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout ?? defaultTimeout);

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
    } on TimeoutException {
      throw Exception('Kết nối quá chậm, vui lòng thử lại');
    } on SocketException catch (e) {
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      if (kDebugMode) print('API POST Error: $e');
      rethrow;
    }
  }

  // ==================== PUT REQUEST WITH TIMEOUT ====================
  Future<T> _put<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser, {
        Duration? timeout,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 PUT Request: $uri');

      final httpClient = getHttpClient();
      final request = await httpClient
          .putUrl(uri)
          .timeout(timeout ?? defaultTimeout);

      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      request.add(utf8.encode(jsonEncode(data)));

      final response = await request
          .close()
          .timeout(timeout ?? defaultTimeout);

      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout ?? defaultTimeout);

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
    } on TimeoutException {
      throw Exception('Kết nối quá chậm, vui lòng thử lại');
    } on SocketException catch (e) {
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      if (kDebugMode) print('API PUT Error: $e');
      rethrow;
    }
  }

  // ==================== DELETE REQUEST WITH TIMEOUT ====================
  Future<T> _delete<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Duration? timeout,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 DELETE Request: $uri');

      final httpClient = getHttpClient();
      final request = await httpClient
          .deleteUrl(uri)
          .timeout(timeout ?? defaultTimeout);

      final headers = await getHeaders();
      headers.forEach((key, value) => request.headers.add(key, value));

      final response = await request
          .close()
          .timeout(timeout ?? defaultTimeout);

      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout ?? defaultTimeout);

      print('DELETE Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return parser(jsonDecode(responseBody));
      } else if (response.statusCode == 204) {
        return parser({'success': true});
      } else if (response.statusCode == 401) {
        await clearAuthToken();
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        print('DELETE Response Body: $responseBody');
        throw Exception('Lỗi ${response.statusCode}: $responseBody');
      }
    } on TimeoutException {
      throw Exception('Kết nối quá chậm, vui lòng thử lại');
    } on SocketException catch (e) {
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      if (kDebugMode) print('API DELETE Error: $e');
      rethrow;
    }
  }

  // Future<T> _uploadFile<T>(
  //     String endpoint,
  //     File file,
  //     T Function(Map<String, dynamic>) fromJson,
  //     ) async {
  //   try {
  //     var uri = Uri.parse('$baseUrl$endpoint');
  //     var request = http.MultipartRequest('POST', uri);
  //
  //     if (_authToken != null) {
  //       request.headers['Authorization'] = 'Bearer $_authToken';
  //     }
  //
  //     var multipartFile = await http.MultipartFile.fromPath(
  //       'file',
  //       file.path,
  //     );
  //     request.files.add(multipartFile);
  //
  //     // Gửi request với timeout
  //     var streamedResponse = await request
  //         .send()
  //         .timeout(uploadTimeout);
  //
  //     var response = await http.Response
  //         .fromStream(streamedResponse)
  //         .timeout(uploadTimeout);
  //
  //     if (response.statusCode == 200) {
  //       var jsonResponse = json.decode(response.body);
  //       return fromJson(jsonResponse);
  //     } else {
  //       var errorResponse = json.decode(response.body);
  //       throw Exception(errorResponse['message'] ?? 'Upload failed');
  //     }
  //   } on TimeoutException {
  //     throw Exception('Upload quá chậm, vui lòng thử lại');
  //   } on SocketException catch (e) {
  //     throw Exception('Lỗi kết nối mạng: ${e.message}');
  //   } catch (e) {
  //     throw Exception('Lỗi upload: $e');
  //   }
  // }

  Future<T> _uploadFile<T>(
      String endpoint,
      File file,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      print('Upload File Request: $baseUrl$endpoint');
      print('File path: ${file.path}');
      print('File size: ${await file.length()} bytes');

      var uri = Uri.parse('$baseUrl$endpoint');
      var request = http.MultipartRequest('POST', uri);

      if (_authToken == null) {
        _authToken = await getAuthToken();
      }

      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
        print('Using auth token');
      }

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mimeTypeSplit = mimeType.split('/');

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1]),
      );
      request.files.add(multipartFile);

      print('File content-type: $mimeType');
      print('Sending upload request...');

      var streamedResponse = await request
          .send()
          .timeout(uploadTimeout);

      var response = await http.Response
          .fromStream(streamedResponse)
          .timeout(uploadTimeout);

      print('Upload Response Status: ${response.statusCode}');
      print('Upload Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          print('Upload thành công!');
          return fromJson(jsonResponse);
        } catch (e) {
          print('Lỗi parse JSON response: $e');
          throw Exception('Lỗi xử lý dữ liệu phản hồi: $e');
        }
      } else {
        try {
          var errorResponse = json.decode(response.body);
          String errorMsg = errorResponse['message'] ??
              errorResponse['error'] ??
              errorResponse['title'] ??
              'Upload failed with status ${response.statusCode}';
          print('Upload thất bại: $errorMsg');
          throw Exception(errorMsg);
        } catch (e) {
          print('Upload thất bại: ${response.body}');
          throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
        }
      }
    } on TimeoutException {
      print('Upload timeout sau ${uploadTimeout.inSeconds}s');
      throw Exception('Upload quá chậm, vui lòng thử lại');
    } on SocketException catch (e) {
      print('Lỗi kết nối mạng: ${e.message}');
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      print('Lỗi upload: $e');
      throw Exception('Lỗi upload: $e');
    }
  }

  // ==================== PUBLIC API METHODS ====================
  Future<T> Get<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Map<String, dynamic>? queryParams,
        Duration? timeout,
      }) =>
      _get(endpoint, parser, queryParams: queryParams, timeout: timeout);

  Future<T> Post<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser, {
        Duration? timeout,
      }) =>
      _post(endpoint, data, parser, timeout: timeout);

  Future<T> Put<T>(
      String endpoint,
      dynamic data,
      T Function(dynamic) parser, {
        Duration? timeout,
      }) =>
      _put(endpoint, data, parser, timeout: timeout);

  Future<T> Delete<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Duration? timeout,
      }) =>
      _delete(endpoint, parser, timeout: timeout);

  Future<T> UploadFile<T>(
      String endpoint,
      File file,
      T Function(Map<String, dynamic>) fromJson,
      ) =>
      _uploadFile(endpoint, file, fromJson);
}