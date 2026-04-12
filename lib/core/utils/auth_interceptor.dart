import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;

  AuthInterceptor({required this.sharedPreferences});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = sharedPreferences.getString('jwt_token');
    final fullUrl = '${options.baseUrl}${options.path}';

    print('DIO REQUEST: [${options.method}] $fullUrl');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('AUTH: Token attached to request');
    } else {
      print('AUTH: No token found in SharedPreferences');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('DIO ERROR: [${err.requestOptions.method}] ${err.requestOptions.baseUrl}${err.requestOptions.path}');
    print('ERROR MESSAGE: ${err.message}');
    if (err.response != null) {
      print('STATUS CODE: ${err.response?.statusCode}');
      print('RESPONSE DATA: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
