import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:todo_app/services/local_storage_service.dart';
import 'package:todo_app/utils/global.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    /// Put the paths you want the interceptor to ignore
    options.headers[HttpHeaders.acceptHeader] = 'application/json';
    final token = await LocalStorageService.i.getStorageValue(
      kToken,
    ); //new "token"
    if (!options.path.contains('/login') &&
        !options.path.contains('/register')) {
      /// Fetch your token from local storage (or wherever) and plug it in
      // var token = '<YOUR-TOKEN-HERE>'; //uncomment
      options.headers[HttpHeaders.authorizationHeader] =
          'Bearer $token'; //uncomment
    }
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An error occurred';

    switch (err.type) {
      case DioExceptionType.cancel:
        errorMessage = 'Request to API server was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection to API server timed out';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout in connection with API server';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout in connection with API server';
        break;
      case DioExceptionType.badResponse:
        if (err.response != null) {
          if (err.response!.data != null) {
            if (err.response!.data is String) {
              errorMessage =
                  '${err.response!.statusCode}: ${err.response!.data}';
            } else if (err.response!.data is Map) {
              // Try to get message from response data
              final data = err.response!.data as Map;
              errorMessage =
                  data['message']?.toString() ??
                  data['error']?.toString() ??
                  'An error occurred (Status: ${err.response!.statusCode})';
            } else {
              errorMessage =
                  'An error occurred (Status: ${err.response!.statusCode})';
            }

            // Override with specific status code messages
            if (err.response!.statusCode == 404) {
              errorMessage = err.response!.data is String
                  ? '${err.response!.statusCode} Page not found.'
                  : '404: Resource not found';
            } else if (err.response!.statusCode == 500) {
              errorMessage = err.response!.data is String
                  ? '${err.response!.statusCode} Internal server error.'
                  : '500: Internal server error';
            } else if (err.response!.statusCode == 401) {
              errorMessage = 'Unauthenticated - Please login again';
            } else if (err.response!.statusCode == 403) {
              errorMessage = 'Unauthorized - You do not have permission';
            }
          } else {
            errorMessage =
                'Received invalid status code: ${err.response!.statusCode}';
          }
        } else {
          errorMessage = 'Received invalid response from server';
        }
        break;

      case DioExceptionType.unknown:
        // Extract actual error message if available
        if (err.error != null) {
          final errorStr = err.error.toString();
          if (errorStr.contains('Failed host lookup') ||
              errorStr.contains('SocketException')) {
            errorMessage =
                'Connection failed: Unable to reach the server. Please check your internet connection.';
          } else if (errorStr.contains('Network is unreachable')) {
            errorMessage =
                'Network is unreachable. Please check your internet connection.';
          } else {
            errorMessage = 'Connection to API server failed: ${err.error}';
          }
        } else {
          errorMessage =
              'Connection to API server failed due to internet connection';
        }
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad Certificate - SSL certificate validation failed';
        break;
      case DioExceptionType.connectionError:
        // Extract actual connection error message if available
        if (err.error != null) {
          final errorStr = err.error.toString();
          if (errorStr.contains('Failed host lookup') ||
              errorStr.contains('SocketException')) {
            errorMessage =
                'Connection error: Unable to reach the server. Please check your internet connection.';
          } else {
            errorMessage = 'Connection error: ${err.error}';
          }
        } else {
          errorMessage = 'Connection error - Unable to connect to the server';
        }
        break;
    }

    err = err.copyWith(error: errorMessage);
    handler.next(err);
  }
}

class UserAgentInterceptor extends Interceptor {
  @override
  Future<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var packageInfo = await PackageInfo.fromPlatform();
    options.headers['User-Agent'] =
        '${packageInfo.appName} - ${packageInfo.packageName}/${packageInfo.version}+${packageInfo.buildNumber} - Dart/${Platform.version} - OS: ${Platform.operatingSystem}/${Platform.operatingSystemVersion}';
    handler.next(options);
  }
}
