import 'package:todo_app/models/upcoming_task_list_model.dart';

abstract class UpcomingTaskState {}

class UpcomingTaskInitial extends UpcomingTaskState {}

class UpcomingTaskLoading extends UpcomingTaskState {}

class UpcomingTaskSuccess extends UpcomingTaskState {
  final List<UpComingTasks> tasks;
  UpcomingTaskSuccess({required this.tasks});
}

class UpcomingTaskFailure extends UpcomingTaskState {
  final String error;
  UpcomingTaskFailure({required this.error});
}

