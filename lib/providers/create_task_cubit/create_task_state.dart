abstract class CreateTaskState {}

class CreateTaskInitial extends CreateTaskState {}

class CreateTaskLoading extends CreateTaskState {}

class CreateTaskSuccess extends CreateTaskState {
  final Map<String, dynamic> data;
  CreateTaskSuccess({required this.data});
}

class CreateTaskFailure extends CreateTaskState {
  final String error;
  CreateTaskFailure({required this.error});
}

