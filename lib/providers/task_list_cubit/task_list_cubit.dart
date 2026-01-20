import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/task_list_cubit/task_list_state.dart';
import 'package:todo_app/repository/home_repository.dart';

class TaskListCubit extends Cubit<TaskListState> {
  final HomeRepository homeRepository;
  TaskListCubit(this.homeRepository) : super(TaskListInitial());
  Future<void> getTasks() async {
    emit(TaskListLoading());
    final result = await homeRepository.getTasks();
    result.either(
      (left) {
        emit(TaskListFailure(error: left));
      },
      (right) {
        emit(TaskListSuccess(tasks: right));
      },
    );
  }
}
