import 'package:todo_app/models/tasks_model.dart';

abstract class TaskListState {}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListSuccess extends TaskListState {
  final List<Tasks> tasks;
  TaskListSuccess({required this.tasks});
}

class TaskListFailure extends TaskListState {
  final String error;
  TaskListFailure({required this.error});
}
