import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SocialLoginUseCase socialLoginUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.socialLoginUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSocialLoginRequested(SocialLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await socialLoginUseCase(SocialLoginParams(connection: event.connection));
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}
