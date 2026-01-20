import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/users_list_cubit/users_list_state.dart';
import 'package:todo_app/repository/users_activity_repository.dart';

class UsersListCubit extends Cubit<UsersListState> {
  final UsersActivityRepository usersActivityRepository;
  UsersListCubit(this.usersActivityRepository) : super(UsersListInitial());

  Future<void> getAllUsersList() async {
    emit(UsersListLoading());
    final result = await usersActivityRepository.getAllUsersList();
    result.either(
      (left) {
        emit(UsersListFailure(error: left));
      },
      (right) {
        emit(UsersListSuccess(users: right));
      },
    );
  }
}

