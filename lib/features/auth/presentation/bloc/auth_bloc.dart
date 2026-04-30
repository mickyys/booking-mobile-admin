import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../notification/domain/usecases/register_device_usecase.dart';
import '../../../notification/presentation/notification_manager.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SocialLoginUseCase socialLoginUseCase;
  final RegisterDeviceUseCase registerDeviceUseCase;
  final NotificationManager notificationManager;

  AuthBloc({
    required this.loginUseCase,
    required this.socialLoginUseCase,
    required this.registerDeviceUseCase,
    required this.notificationManager,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    debugPrint('AUTH BLOC: Login requested for ${event.email}');
    emit(AuthLoading());
    
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) {
        debugPrint('AUTH BLOC: Login failed - ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        debugPrint('AUTH BLOC: Login success - User: ${user.id}');
        emit(AuthAuthenticated(user: user));
        
        _registerDeviceForNotifications();
      },
    );
  }

  Future<void> _onSocialLoginRequested(SocialLoginRequested event, Emitter<AuthState> emit) async {
    debugPrint('AUTH BLOC: Social login requested - ${event.connection}');
    emit(AuthLoading());
    
    final result = await socialLoginUseCase(SocialLoginParams(connection: event.connection));
    result.fold(
      (failure) {
        debugPrint('AUTH BLOC: Social login failed - ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        debugPrint('AUTH BLOC: Social login success - User: ${user.id}');
        emit(AuthAuthenticated(user: user));
        
        _registerDeviceForNotifications();
      },
    );
  }

  Future<void> _registerDeviceForNotifications() async {
    try {
      debugPrint('[AuthBloc] Registering device for notifications...');
      
      final token = await notificationManager.getFCMToken();
      
      if (token != null) {
        final result = await registerDeviceUseCase(token);
        result.fold(
          (failure) {
            debugPrint('[AuthBloc] Failed to register device: ${failure.message}');
          },
          (_) {
            debugPrint('[AuthBloc] Device registered successfully for notifications');
          },
        );
      } else {
        debugPrint('[AuthBloc] Could not get FCM token');
      }
    } catch (e) {
      debugPrint('[AuthBloc] Error registering device: $e');
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    debugPrint('AUTH BLOC: Logout requested');
    emit(AuthUnauthenticated());
  }
}
