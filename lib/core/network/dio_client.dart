import 'package:dio/dio.dart';

import '../constants/api.dart';

class DioClient {
  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.tmdbBaseUrl,
            headers: {
              'Authorization': 'Bearer ${ApiConstants.tmdbToken}',
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
          ),
        );

  final Dio dio;
}
