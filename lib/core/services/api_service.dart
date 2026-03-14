import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // debugPrint এর জন্য

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';



class ApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();

  late final Dio _dio;
  final String baseUrl = ApiConstants.baseUrl;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          // Add token to requests
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired - try to refresh
            try {
              final String? newToken = await _refreshToken();
              if (newToken != null && newToken.isNotEmpty) {
                // Retry the request with new token
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final Response<dynamic> response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              debugPrint('Token refresh failed: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  Future<String?> _refreshToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final Response<dynamic> response = await _dio.post(
        ApiConstants.refreshToken,
        data: <String, String>{'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        if (newToken != null) {
          await prefs.setString('auth_token', newToken);
          return newToken;
        }
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return null;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // GET request
  Future<Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    await _ensureInitialized();
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    await _ensureInitialized();
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    await _ensureInitialized();
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    await _ensureInitialized();
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    await _ensureInitialized();
    try {
      return await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart file upload
  Future<Response> uploadFile(
      String endpoint,
      String filePath, {
        Map<String, dynamic>? data,
        String fileField = 'file',
      }) async {
    await _ensureInitialized();
    try {
      final String fileName = filePath.split('/').last;
      final FormData formData = FormData.fromMap(<String, dynamic>{
        fileField: await MultipartFile.fromFile(filePath, filename: fileName),
        if (data != null) ...data,
      });

      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: <String, dynamic>{'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<Response> downloadFile(
      String url,
      String savePath, {
        ProgressCallback? onReceiveProgress,
      }) async {
    await _ensureInitialized();
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    var message = 'Something went wrong';

    if (error.response != null) {
      final int? statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map) {
        message = data['message'] ?? data['error'] ?? 'Error $statusCode';
      } else if (data is String) {
        message = data;
      } else {
        message = 'Error $statusCode';
      }

      switch (statusCode) {
        case 400:
          message = 'Bad request';
          break;
        case 401:
          message = 'Unauthorized - Please login again';
          break;
        case 403:
          message = "Forbidden - You don't have permission";
          break;
        case 404:
          message = 'Resource not found';
          break;
        case 500:
          message = 'Server error - Please try again later';
          break;
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Receive timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Send timeout';
          break;
        case DioExceptionType.cancel:
          message = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection';
          break;
        default:
          message = 'Network error';
      }
    }

    return Exception(message);
  }

  Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  Future<void> setToken(String token, {String? refreshToken}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}