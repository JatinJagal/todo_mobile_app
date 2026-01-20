import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/upcoming_task_cubit/upcoming_task_state.dart';
import 'package:todo_app/repository/home_repository.dart';

class UpcomingTaskCubit extends Cubit<UpcomingTaskState> {
  final HomeRepository homeRepository;
  UpcomingTaskCubit(this.homeRepository) : super(UpcomingTaskInitial());

  Future<void> getUpcomingTasks() async {
    emit(UpcomingTaskLoading());
    final result = await homeRepository.getUpcomingTasks();
    result.either(
      (left) {
        emit(UpcomingTaskFailure(error: left));
      },
      (right) {
        emit(UpcomingTaskSuccess(tasks: right));
      },
    );
  }
}

