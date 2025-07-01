import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/news_model.dart';

class ApiService {
  static const String baseUrl = 'http://45.149.187.204:3000/api';
  static String? _token;

  static const Duration _timeout = Duration(seconds: 10);

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'close',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _simpleRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);
    http.Response response;
    final client = http.Client();

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: _headers).timeout(_timeout);
          break;
        case 'POST':
          response = await client
              .post(uri, headers: _headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await client
              .put(uri, headers: _headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: _headers).timeout(_timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } finally {
      client.close();
    }

    Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      responseData = {
        'status': response.statusCode,
        'body': {
          'message': response.body.isEmpty ? 'No response body' : response.body,
        },
      };
    }

    return {
      'statusCode': response.statusCode,
      'data': responseData,
    };
  }

  // AUTH
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Gunakan akun guest jika input kosong
    if (email.trim().isEmpty || password.trim().isEmpty) {
      email = "guest@demo.com";
      password = "guest123";
    }

    final result = await _simpleRequest('POST', '$baseUrl/auth/login', body: {
      'email': email,
      'password': password,
    });

    if (result['statusCode'] == 200 &&
        result['data']['body']['success'] == true) {
      return result['data'];
    } else {
      final errorMessage = result['data']['body']['message'] ?? 'Login gagal';
      throw Exception('Login gagal: $errorMessage');
    }
  }

  static Future<User> getMe() async {
    final result = await _simpleRequest('GET', '$baseUrl/auth/me');
    if (result['statusCode'] == 200) {
      return User.fromJson(result['data']['body']['data']);
    } else {
      throw Exception('Gagal mendapatkan info user');
    }
  }

  // NEWS (Author)
  static Future<List<News>> getAuthorNews() async {
    final result = await _simpleRequest('GET', '$baseUrl/author/news');
    if (result['statusCode'] == 200) {
      return (result['data']['body']['data'] as List)
          .map((item) => News.fromJson(item))
          .toList();
    } else {
      throw Exception('Gagal mengambil berita author');
    }
  }

  static Future<News> createNews(News news) async {
    final result =
        await _simpleRequest('POST', '$baseUrl/author/news', body: news.toJson());

    if ((result['statusCode'] == 200 || result['statusCode'] == 201) &&
        result['data']['body']['success'] == true) {
      return News.fromJson(result['data']['body']['data']);
    } else {
      final message = result['data']['body']['message'] ?? 'Gagal membuat berita';
      throw Exception(message);
    }
  }

  static Future<News> updateNews(String id, News news) async {
    final result =
        await _simpleRequest('PUT', '$baseUrl/author/news/$id', body: news.toJson());

    if (result['statusCode'] == 200 &&
        result['data']['body']['success'] == true) {
      return News.fromJson(result['data']['body']['data']);
    } else {
      final message = result['data']['body']['message'] ?? 'Gagal update berita';
      throw Exception(message);
    }
  }

  static Future<bool> deleteNews(String id) async {
    final result = await _simpleRequest('DELETE', '$baseUrl/author/news/$id');
    if (result['statusCode'] == 200 || result['statusCode'] == 204) {
      return true;
    } else {
      final message = result['data']['body']['message'] ?? 'Gagal hapus berita';
      throw Exception(message);
    }
  }

  // NEWS (Public)
  static Future<List<News>> getPublicNews() async {
    final result = await _simpleRequest('GET', '$baseUrl/news');
    if (result['statusCode'] == 200) {
      return (result['data']['body']['data'] as List)
          .map((item) => News.fromJson(item))
          .toList();
    } else {
      throw Exception('Gagal mengambil berita publik');
    }
  }

  static Future<News> getNewsBySlug(String slug) async {
    final result = await _simpleRequest('GET', '$baseUrl/news/$slug');
    if (result['statusCode'] == 200) {
      return News.fromJson(result['data']['body']['data']);
    } else {
      throw Exception('Gagal mengambil berita by slug');
    }
  }
}
