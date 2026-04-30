import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class RegisterDeviceUseCase implements UseCase<void, String> {
  final NotificationRepository repository;

  RegisterDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String token) async {
    return await repository.registerDevice(token);
  }
}
