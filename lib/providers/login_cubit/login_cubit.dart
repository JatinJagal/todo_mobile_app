import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/login_cubit/login_state.dart';
import 'package:todo_app/repository/auth_repository.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;
  LoginCubit(this.authRepository) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    final result = await authRepository.login(email, password);
    result.either(
      (left) {
        emit(LoginFailure(error: left));
      },
      (right) {
        emit(LoginSuccess(data: right));
      },
    );
  }
}
