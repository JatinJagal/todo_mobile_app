import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_state.dart';
import 'package:todo_app/repository/auth_repository.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final AuthRepository authRepository;
  UserProfileCubit(this.authRepository) : super(UserProfileInitial());

  Future<void> getUserProfile() async {
    emit(UserProfileLoading());
    final result = await authRepository.getUserProfile();
    result.either(
      (left) {
        emit(UserProfileFailure(error: left));
      },
      (right) {
        emit(UserProfileSuccess(data: right));
      },
    );
  }
}
