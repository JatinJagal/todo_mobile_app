import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/create_task_cubit/create_task_state.dart';
import 'package:todo_app/repository/home_repository.dart';

class CreateTaskCubit extends Cubit<CreateTaskState> {
  final HomeRepository homeRepository;
  CreateTaskCubit(this.homeRepository) : super(CreateTaskInitial());

  Future<void> createTask({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
  }) async {
    emit(CreateTaskLoading());
    final result = await homeRepository.createTask(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
    );
    result.either(
      (left) {
        emit(CreateTaskFailure(error: left));
      },
      (right) {
        emit(CreateTaskSuccess(data: right));
      },
    );
  }
}

