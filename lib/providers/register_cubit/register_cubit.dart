import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/register_cubit/register_state.dart';
import 'package:todo_app/repository/auth_repository.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository authRepository;
  RegisterCubit(this.authRepository) : super(RegisterInitial());

  Future register(
    String name,
    String email,
    String password,
    String confirmPassword,
    File? imageFile,
  ) async {
    emit(RegisterLoading());
    final result = await authRepository.register(
      name,
      email,
      password,
      confirmPassword,
      imageFile,
    );
    // result.fold(
    //   (l) => emit(RegisterFailure(error: l)),
    //   (r) => emit(RegisterSuccess(data: r)),
    // );
    result.either(
      (left) {
        emit(RegisterFailure(error: left));
      },
      (right) {
        emit(RegisterSuccess(data: right));
      },
    );
  }
}
