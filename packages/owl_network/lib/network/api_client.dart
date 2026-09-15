// language: Dart, file: packages/owl_network/lib/network/api_client.dart, target: Flutter / Owl MOBA HUD

import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl_core/owl_core.dart';

/// Provider for the configured Dio HTTP instance.
final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    connectTimeout: AppConstants.networkTimeout,
    receiveTimeout: AppConstants.networkTimeout,
    sendTimeout: AppConstants.networkTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-App': AppConstants.appTitle,
      'X-Client-Version': AppConstants.appVersion,
    },
    responseType: ResponseType.json,
  );

  final dio = Dio(options);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log(
          'HTTP [${options.method}] => ${options.uri}',
          name: 'Owl.ApiClient',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
          'HTTP [${response.statusCode}] <= ${response.requestOptions.uri}',
          name: 'Owl.ApiClient',
        );
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        developer.log(
          'HTTP Error [${error.response?.statusCode ?? "NO_STATUS"}] on ${error.requestOptions.uri}: ${error.message}',
          name: 'Owl.ApiClient',
          error: error,
          stackTrace: error.stackTrace,
        );
        return handler.next(error);
      },
    ),
  );

  return dio;
});

/// Provider for the high-level ApiClient wrapper.
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

/// High-level HTTP client wrapper providing unified error handling and REST methods.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Direct access to underlying configured [Dio] instance.
  Dio get rawDio => _dio;

  /// Perform a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected network error: $e',
        details: e,
      );
    }
  }

  /// Perform a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected network error: $e',
        details: e,
      );
    }
  }

  /// Perform a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected network error: $e',
        details: e,
      );
    }
  }

  /// Perform a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected network error: $e',
        details: e,
      );
    }
  }

  /// Perform a streaming POST request (e.g. For LLM responses).
  Future<ResponseBody> postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<ResponseBody>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            ...?headers,
          },
        ),
        cancelToken: cancelToken,
      );

      final body = response.data;
      if (body == null) {
        throw const NetworkException(
          message: 'Received empty response body for stream request.',
          code: 'EMPTY_STREAM_RESPONSE',
        );
      }
      return body;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected stream error: $e',
        details: e,
      );
    }
  }

  /// Translates [DioException] to domain-level [NetworkException].
  NetworkException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout(
          message: 'Connection timed out (${error.type.name}): ${error.message}',
        );

      case DioExceptionType.badResponse:
        return NetworkException.serverError(
          statusCode: error.response?.statusCode,
          message: error.response?.statusMessage ?? error.message,
          details: error.response?.data,
        );

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return NetworkException.noInternet(
          message: 'Unable to connect to host: ${error.message}',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security error: Bad SSL certificate.',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: error.message ?? 'An unknown network error occurred.',
          code: 'UNKNOWN_NETWORK_ERROR',
          details: error.error,
        );
    }
  }
}
