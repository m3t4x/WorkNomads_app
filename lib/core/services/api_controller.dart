import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiController {
  static const String _defaultBaseUrl = 'http://localhost:8001';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _baseUrlKey = 'api_base_url';
  
  late Dio _dio;
  late SharedPreferences _prefs;
  String? _accessToken;
  String? _refreshToken;
  String _baseUrl = _defaultBaseUrl;
  
  ApiController._internal();
  static final ApiController _instance = ApiController._internal();
  factory ApiController() => _instance;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _accessToken = _prefs.getString(_accessTokenKey);
    _refreshToken = _prefs.getString(_refreshTokenKey);
    _baseUrl = _prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  // Attempt to refresh access token if refresh token exists. Returns true if refreshed.
  Future<bool> tryRefresh() async {
    if (_refreshToken == null) return false;
    try {
      await _refreshAccessToken();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            try {
              await _refreshAccessToken();
              
              // Retry the original request
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
              
              final cloneReq = await _dio.request(
                opts.path,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                ),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );
              
              return handler.resolve(cloneReq);
            } catch (e) {
              await clearTokens();
              return handler.next(error);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/auth/login/', data: {
        // API accepts either {"username": "..."} or {"email": "..."}
        'username': usernameOrEmail,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // SimpleJWT-style payload: { access: '...', refresh: '...' }
        final access = data['access'] as String?;
        final refresh = data['refresh'] as String?;
        if (access != null) {
          await _saveTokens(accessToken: access, refreshToken: refresh);
        }
        
        return {
          'success': true,
          'message': 'Login successful',
        };
      }
      
      return {
        'success': false,
        'message': 'Login failed',
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/auth/register/', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'username': username,
        'password': password,
      });

      if (response.statusCode == 201) {
        // API returns a detail message; tokens should be obtained by calling login afterwards.
        final data = response.data as Map<String, dynamic>?;
        final detail = data?['detail'] ?? 'Registration successful';
        return {
          'success': true,
          'message': detail,
        };
      }
      
      return {
        'success': false,
        'message': 'Registration failed',
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) throw Exception('No refresh token available');
    
    final response = await _dio.post('/api/auth/login/refresh/', data: {
      'refresh': _refreshToken,
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final newAccess = data['access'] as String?;
      if (newAccess == null) throw Exception('Token refresh failed');
      await _saveTokens(
        accessToken: newAccess,
        // refresh remains the same for typical refresh flows
        refreshToken: null,
      );
    } else {
      throw Exception('Token refresh failed');
    }
  }

  Future<void> _saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
    
    await _prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await _dio.post('/api/auth/logout/');
      }
    } catch (e) {
      // Ignore logout errors, just clear local tokens
    } finally {
      await clearTokens();
    }
  }

  // Base URL management
  String get baseUrl => _baseUrl;
  Future<void> setBaseUrl(String url) async {
    // Normalize URL (remove trailing spaces)
    final normalized = url.trim();
    _baseUrl = normalized.isEmpty ? _defaultBaseUrl : normalized;
    await _prefs.setString(_baseUrlKey, _baseUrl);
    // Update Dio instance
    _dio.options.baseUrl = _baseUrl;
  }

  Map<String, dynamic> _handleError(DioException error) {
    String message = 'An error occurred';

    String extractMessage(dynamic data) {
      if (data == null) return message;
      // If backend returns a raw string
      if (data is String && data.trim().isNotEmpty) return data;
      if (data is Map<String, dynamic>) {
        // Common DRF/simplejwt keys
        if (data['detail'] is String) return data['detail'];
        if (data['message'] is String) return data['message'];
        if (data['error'] is String) return data['error'];
        if (data['non_field_errors'] is List && data['non_field_errors'].isNotEmpty) {
          final first = data['non_field_errors'].first;
          if (first is String) return first;
        }
        // Field errors: take first field:first error
        for (final entry in data.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty) {
            final first = v.first;
            if (first is String) {
              return first;
            }
          } else if (v is String && v.isNotEmpty) {
            return v;
          }
        }
      }
      return message;
    }

    if (error.response != null) {
      final status = error.response!.statusCode ?? 0;
      final data = error.response!.data;
      message = extractMessage(data);
      // Reasonable fallbacks by status
      if ((message.isEmpty || message == 'An error occurred')) {
        if (status == 400 || status == 422) message = 'Invalid request. Please check your input.';
        if (status == 401) message = 'Invalid credentials. Please try again.';
        if (status == 403) message = 'Permission denied.';
        if (status == 404) message = 'Not found.';
        if (status >= 500) message = 'Server error. Please try again later.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Triple-tap to set API URLs.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Server response timeout. Triple-tap to set API URLs.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Network error or unreachable API. Triple-tap to set API URLs.';
    } else if (error.type == DioExceptionType.unknown) {
      message = 'Network error or unreachable API. Triple-tap to set API URLs.';
    }
    // SocketException fallback
    final underlying = error.error;
    if (underlying != null && underlying.toString().contains('SocketException')) {
      message = 'Network error or unreachable API. Triple-tap to set API URLs.';
    }

    // No response and no specific mapping above hit: show triple-tap guidance
    if (error.response == null && (message.isEmpty || message == 'An error occurred')) {
      message = 'Network error or unreachable API. Triple-tap to set API URLs.';
    }

    // Final fallback: for connection-related errors, prefer actionable guidance
    if ((message.isEmpty || message == 'An error occurred') &&
        (error.type == DioExceptionType.connectionTimeout ||
         error.type == DioExceptionType.receiveTimeout ||
         error.type == DioExceptionType.connectionError ||
         error.type == DioExceptionType.unknown)) {
      message = 'Network error or unreachable API. Triple-tap to set API URLs.';
    }

    return {
      'success': false,
      'message': message,
    };
  }

  // Getters
  bool get isLoggedIn => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasRefreshToken => _refreshToken != null;
  
  // Generic API methods for future use
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
