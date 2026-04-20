import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reservaloya_admin/features/users/domain/usecases/get_users_usecase.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_event.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;

  UsersBloc({required this.getUsersUseCase}) : super(UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final result = await getUsersUseCase();
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }
}
