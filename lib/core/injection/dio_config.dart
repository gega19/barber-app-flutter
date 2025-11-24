import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../services/analytics_service.dart';

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
          // Track API errors (except 401 which is handled above)
          _trackApiError(error, sl);
          handler.next(error);
        }
      },
    );
  }

  /// Track API errors con información detallada
  static void _trackApiError(DioException error, GetIt sl) {
    try {
      final analyticsService = sl<AnalyticsService>();

      // Preparar información detallada del request
      final requestData = <String, dynamic>{
        'endpoint': error.requestOptions.path,
        'method': error.requestOptions.method,
        'baseUrl': error.requestOptions.baseUrl,
        'queryParameters': error.requestOptions.queryParameters,
        if (error.requestOptions.data != null)
          'requestBody': _sanitizeRequestBody(error.requestOptions.data),
        'headers': _sanitizeHeaders(error.requestOptions.headers),
      };

      // Preparar información de la respuesta
      final responseData = <String, dynamic>{
        'statusCode': error.response?.statusCode,
        'statusMessage': error.response?.statusMessage,
        if (error.response?.data != null)
          'responseBody': _sanitizeResponseBody(error.response!.data),
      };

      // Determinar severidad basada en el tipo de error
      String severity = 'medium';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        severity = 'high';
      } else if (error.response?.statusCode != null) {
        final statusCode = error.response!.statusCode!;
        if (statusCode >= 500) {
          severity = 'high';
        } else if (statusCode == 404 || statusCode == 400) {
          severity = 'low';
        } else if (statusCode == 403 || statusCode == 401) {
          severity = 'medium';
        }
      } else if (error.type == DioExceptionType.connectionError) {
        severity = 'high';
      }

      // Contexto adicional
      final context = <String, dynamic>{
        'endpoint': error.requestOptions.path,
        'method': error.requestOptions.method,
        'errorType': error.type.toString(),
      };

      analyticsService.trackError(
        errorName: 'api_error',
        errorType: 'api_error',
        error: error,
        stackTrace: error.stackTrace,
        context: context,
        severity: severity,
        requestData: requestData,
        responseData: responseData,
      );
    } catch (e) {
      // Silently fail to avoid breaking the error flow
      print('Error tracking API error: $e');
    }
  }

  /// Sanitiza el request body para no incluir información sensible
  static dynamic _sanitizeRequestBody(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();
        // Remover campos sensibles
        if (keyStr.contains('password') ||
            keyStr.contains('token') ||
            keyStr.contains('secret') ||
            keyStr.contains('key') ||
            keyStr.contains('auth')) {
          sanitized[key.toString()] = '[REDACTED]';
        } else if (value is Map) {
          sanitized[key.toString()] = _sanitizeRequestBody(value);
        } else if (value is List) {
          sanitized[key.toString()] = value.map((item) {
            if (item is Map) {
              return _sanitizeRequestBody(item);
            }
            return item;
          }).toList();
        } else {
          sanitized[key.toString()] = value;
        }
      });
      return sanitized;
    }

    if (data is String) {
      // Limitar tamaño de strings
      return data.length > 500 ? '${data.substring(0, 500)}...' : data;
    }

    // Para otros tipos, convertir a string y limitar
    final dataStr = data.toString();
    return dataStr.length > 200 ? '${dataStr.substring(0, 200)}...' : dataStr;
  }

  /// Sanitiza headers para no incluir tokens
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      final keyLower = key.toLowerCase();
      if (keyLower == 'authorization' ||
          keyLower.contains('token') ||
          keyLower.contains('secret') ||
          keyLower.contains('key')) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Sanitiza response body (limitar tamaño y remover datos sensibles)
  static dynamic _sanitizeResponseBody(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return _sanitizeRequestBody(data);
    }

    if (data is String) {
      return data.length > 500 ? '${data.substring(0, 500)}...' : data;
    }

    if (data is List) {
      return data.map((item) => _sanitizeResponseBody(item)).toList();
    }

    final dataStr = data.toString();
    return dataStr.length > 200 ? '${dataStr.substring(0, 200)}...' : dataStr;
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
