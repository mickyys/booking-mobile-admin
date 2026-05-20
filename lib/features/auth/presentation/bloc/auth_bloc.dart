import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/auth_state_notifier.dart';
import '../../../notification/domain/usecases/register_device_usecase.dart';
import '../../../notification/presentation/notification_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SocialLoginUseCase socialLoginUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final AuthRepository authRepository;
  final RegisterDeviceUseCase registerDeviceUseCase;
  final NotificationManager notificationManager;
  final AuthStateNotifier authStateNotifier;

  AuthBloc({
    required this.loginUseCase,
    required this.socialLoginUseCase,
    required this.refreshTokenUseCase,
    required this.authRepository,
    required this.registerDeviceUseCase,
    required this.notificationManager,
    required this.authStateNotifier,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    debugPrint('AUTH BLOC: App started - checking auth status');
    emit(AuthChecking());

    final hasToken = await authRepository.hasToken();
    if (!hasToken) {
      debugPrint('AUTH BLOC: No saved token found');
      authStateNotifier.setUnauthenticated();
      emit(AuthUnauthenticated());
      return;
    }

    final result = await refreshTokenUseCase(const NoParams());
    result.fold(
      (failure) {
        debugPrint('AUTH BLOC: Token refresh failed - ${failure.message}');
        authStateNotifier.setUnauthenticated();
        emit(AuthUnauthenticated());
      },
      (user) {
        debugPrint('AUTH BLOC: Token refreshed successfully - User: ${user.id}');
        authStateNotifier.setAuthenticated();
        emit(AuthAuthenticated(user: user));
        _registerDeviceForNotifications();
      },
    );
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
        authStateNotifier.setAuthenticated();
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
        authStateNotifier.setAuthenticated();
        emit(AuthAuthenticated(user: user));
        
        _registerDeviceForNotifications();
      },
    );
  }

  Future<void> _onRefreshTokenRequested(RefreshTokenRequested event, Emitter<AuthState> emit) async {
    debugPrint('AUTH BLOC: Token refresh requested');
    emit(AuthChecking());

    final result = await refreshTokenUseCase(const NoParams());
    result.fold(
      (failure) {
        debugPrint('AUTH BLOC: Token refresh failed - ${failure.message}');
        authStateNotifier.setUnauthenticated();
        emit(AuthUnauthenticated());
      },
      (user) {
        debugPrint('AUTH BLOC: Token refreshed - User: ${user.id}');
        authStateNotifier.setAuthenticated();
        emit(AuthAuthenticated(user: user));
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

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    debugPrint('AUTH BLOC: Logout requested');
    await authRepository.logout();
    authStateNotifier.setUnauthenticated();
    emit(AuthUnauthenticated());
  }

  Future<void> _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) async {
    debugPrint('AUTH BLOC: Session expired');
    await authRepository.logout();
    authStateNotifier.setUnauthenticated();
    emit(AuthUnauthenticated());
  }
}
