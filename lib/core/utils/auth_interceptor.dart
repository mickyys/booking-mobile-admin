import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'auth_state_notifier.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;
  final AuthRepository authRepository;
  final AuthStateNotifier authStateNotifier;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.sharedPreferences,
    required this.authRepository,
    required this.authStateNotifier,
  });

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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print(
      'DIO ERROR: [${err.requestOptions.method}] ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    print('ERROR MESSAGE: ${err.message}');
    if (err.response != null) {
      print('STATUS CODE: ${err.response?.statusCode}');
      print('RESPONSE DATA: ${err.response?.data}');
    }

    if (err.response?.statusCode == 401 && !_isRefreshing) {
      print('🔄 DIO: 401 detected, attempting token refresh');
      _isRefreshing = true;

      final result = await authRepository.refreshToken();
      _isRefreshing = false;

      result.fold(
        (_) async {
          print('❌ DIO: Token refresh failed, clearing session');
          await sharedPreferences.remove('jwt_token');
          authStateNotifier.setUnauthenticated();
          handler.next(err);
        },
        (user) async {
          print('✅ DIO: Token refreshed successfully, retrying request');
          try {
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${user.token}';

            final retryDio = Dio(BaseOptions(
              baseUrl: opts.baseUrl,
              connectTimeout: opts.connectTimeout,
              receiveTimeout: opts.receiveTimeout,
            ));
            final response = await retryDio.fetch(opts);
            handler.resolve(response);
          } catch (retryErr) {
            print('❌ DIO: Retry after refresh also failed');
            handler.next(err);
          }
        },
      );
    } else {
      super.onError(err, handler);
    }
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
