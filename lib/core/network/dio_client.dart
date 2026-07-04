import 'package:dio/dio.dart';

import '../constants/api.dart';

class DioClient {
  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.tmdbBaseUrl,
            headers: _buildHeaders(),
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final message = _describeError(error);
          final adaptedError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: message,
            stackTrace: error.stackTrace,
          );
          handler.reject(adaptedError);
        },
      ),
    );
  }

  final Dio dio;

  static Map<String, dynamic> _buildHeaders() {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
    };
    if (ApiConstants.tmdbToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${ApiConstants.tmdbToken}';
    }
    return headers;
  }

  static String _describeError(DioException error) {
    final statusCode = error.response?.statusCode;
    switch (statusCode) {
      case 401:
        return 'TMDB authentication failed. Provide a valid token with --dart-define=TMDB_TOKEN=...';
      case 403:
        return 'TMDB access was forbidden. Confirm that the token has the required permissions.';
      case 404:
        return 'The requested TMDB resource could not be found.';
      case 429:
        return 'TMDB rate limit reached. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'TMDB is temporarily unavailable. Please try again later.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The TMDB request timed out. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'The network connection to TMDB could not be established.';
      default:
        return error.message ?? 'Unable to complete the TMDB request.';
    }
  }
}
