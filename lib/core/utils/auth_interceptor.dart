import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;

  AuthInterceptor({required this.sharedPreferences});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await sharedPreferences.getString('jwt_token');
    final fullUrl = '${options.baseUrl}${options.path}';
    final queryString = options.queryParameters.isNotEmpty 
        ? '?${options.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}' 
        : '';

    print('🔌 DIO REQUEST: [${options.method}] $fullUrl$queryString');
    print('🌐 BASE URL: ${options.baseUrl}');
    if (token != null) {
      print('🔑 TOKEN: $token');
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          print('📋 TOKEN PAYLOAD: $payload');
        }
      } catch (e) {}
      print('🔗 CURL: curl -X GET "$fullUrl$queryString" -H "Authorization: Bearer $token" -H "Content-Type: application/json"');
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      print('⚠️ NO TOKEN FOUND');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'DIO ERROR: [${err.requestOptions.method}] ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    print('ERROR MESSAGE: ${err.message}');
    if (err.response != null) {
      print('STATUS CODE: ${err.response?.statusCode}');
      print('RESPONSE DATA: ${err.response?.data}');
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    print('DIO RESPONSE: [${req.method}] ${req.baseUrl}${req.path}');
    print('STATUS CODE: ${response.statusCode}');
    try {
      print('RESPONSE DATA: ${response.data}');
    } catch (e) {
      print('RESPONSE DATA: <unable to print>');
    }
    super.onResponse(response, handler);
  }
}
