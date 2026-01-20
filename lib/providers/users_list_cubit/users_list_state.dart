import 'package:todo_app/models/list_users_model.dart';

abstract class UsersListState {}

class UsersListInitial extends UsersListState {}

class UsersListLoading extends UsersListState {}

class UsersListSuccess extends UsersListState {
  final List<ListUsersModel> users;
  UsersListSuccess({required this.users});
}

class UsersListFailure extends UsersListState {
  final String error;
  UsersListFailure({required this.error});
}

