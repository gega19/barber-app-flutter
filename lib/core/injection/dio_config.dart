import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';

/// Configuración y creación del cliente HTTP Dio
class DioConfig {
  static Dio createDio(GetIt sl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptores
    dio.interceptors.add(_createAuthInterceptor(dio, sl));

    if (kDebugMode) {
      dio.interceptors.add(_createLogInterceptor());
    }

    return dio;
  }

  /// Crea el interceptor de autenticación con manejo de refresh token
  static Interceptor _createAuthInterceptor(Dio dio, GetIt sl) {
    bool isRefreshing = false;
    final List<Map<String, dynamic>> failedQueue = [];

    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip token for refresh-token endpoint to avoid loops
        if (options.path.contains('/refresh-token')) {
          handler.next(options);
          return;
        }

        try {
          final localStorage = sl<LocalStorage>();
          final token = await localStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('⚠️ Error getting token: $e');
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        // Skip refresh for refresh-token endpoint
        if (error.requestOptions.path.contains('/refresh-token')) {
          handler.next(error);
          return;
        }

        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          final localStorage = sl<LocalStorage>();
          final refreshToken = await localStorage.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            // No refresh token available, logout
            print('⚠️ No refresh token available, logging out...');
            await localStorage.clearAll();
            handler.next(error);
            return;
          }

          // If already refreshing, queue this request
          if (isRefreshing) {
            failedQueue.add({
              'requestOptions': error.requestOptions,
              'handler': handler,
            });
            return;
          }

          isRefreshing = true;

          try {
            // Try to refresh the token
            final authDataSource = sl<AuthRemoteDataSource>();
            final newAccessToken = await authDataSource.refreshToken(
              refreshToken,
            );

            // Save new token
            await localStorage.saveToken(newAccessToken);

            // Update the failed request with new token
            error.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            // Retry the original request
            final response = await dio.fetch(error.requestOptions);
            handler.resolve(response);

            // Process queued requests
            for (final item in failedQueue) {
              try {
                final requestOptions = item['requestOptions'] as RequestOptions;
                final itemHandler = item['handler'] as ErrorInterceptorHandler;
                requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(requestOptions);
                itemHandler.resolve(retryResponse);
              } catch (e) {
                final itemHandler = item['handler'] as ErrorInterceptorHandler;
                itemHandler.reject(error);
              }
            }
            failedQueue.clear();
          } catch (refreshError) {
            // Refresh failed, logout and reject all requests
            print('⚠️ Token refresh failed, logging out...');
            await localStorage.clearAll();

            // Reject all queued requests
            for (final item in failedQueue) {
              final itemHandler = item['handler'] as ErrorInterceptorHandler;
              itemHandler.reject(error);
            }
            failedQueue.clear();

            handler.next(error);
          } finally {
            isRefreshing = false;
          }
        } else {
          handler.next(error);
        }
      },
    );
  }

  /// Crea el interceptor de logging para modo debug
  static Interceptor _createLogInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    );
  }
}
