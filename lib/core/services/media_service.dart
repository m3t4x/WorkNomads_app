import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_file.dart';
import 'api_controller.dart';

class MediaService {
  final ApiController _apiController;
  late Dio _mediaDio;
  late SharedPreferences _prefs;
  String _mediaBaseUrl = 'http://localhost:8002'; // Default media service URL
  static const String _mediaUrlKey = 'media_base_url';

  MediaService(this._apiController) {
    _setupMediaDio();
  }

  Future<void> deleteMedia(int id) async {
    try {
      final response = await _mediaDio.delete('/api/media/delete/$id/');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Delete failed');
      }
    } on DioException catch (e) {
      throw _handleMediaError(e);
    }
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _mediaBaseUrl = _prefs.getString(_mediaUrlKey) ?? _mediaBaseUrl;
    _mediaDio.options.baseUrl = _mediaBaseUrl;
  }

  void _setupMediaDio() {
    _mediaDio = Dio(BaseOptions(
      baseUrl: _mediaBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    _mediaDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _apiController.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  String get mediaBaseUrl => _mediaBaseUrl;

  void setMediaBaseUrl(String url) {
    _mediaBaseUrl = url.trim().isEmpty ? 'http://localhost:8002' : url.trim();
    _mediaDio.options.baseUrl = _mediaBaseUrl;
    _prefs.setString(_mediaUrlKey, _mediaBaseUrl);
  }

  Future<List<MediaFile>> getMediaList() async {
    try {
      final response = await _mediaDio.get('/api/media/list/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => MediaFile.fromJson(item as Map<String, dynamic>)).toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleMediaError(e);
    }
  }

  Future<MediaFile> uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _mediaDio.post(
        '/api/media/upload/image/',
        data: formData,
      );

      if (response.statusCode == 201) {
        return MediaFile.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Upload failed');
    } on DioException catch (e) {
      throw _handleMediaError(e);
    }
  }

  Future<MediaFile> uploadAudio(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _mediaDio.post(
        '/api/media/upload/audio/',
        data: formData,
      );

      if (response.statusCode == 201) {
        return MediaFile.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Upload failed');
    } on DioException catch (e) {
      throw _handleMediaError(e);
    }
  }

  String _handleMediaError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data['detail'] is String) return data['detail'];
        if (data['message'] is String) return data['message'];
        if (data['error'] is String) return data['error'];
      }
      
      final status = error.response!.statusCode ?? 0;
      if (status == 401) return 'Authentication required';
      if (status == 413) return 'File too large';
      if (status >= 500) return 'Server error. Please try again later.';
    }
    
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Triple-tap to set API URLs.';
    }
    if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server response timeout. Triple-tap to set API URLs.';
    }
    if (error.type == DioExceptionType.unknown) {
      return 'Network error or unreachable API. Triple-tap to set API URLs.';
    }
    
    return 'Upload failed. Please try again.';
  }
}
