import 'package:todo_app/models/user_profile_model.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileSuccess extends UserProfileState {
  final UserProfileModel data;
  UserProfileSuccess({required this.data});
}

class UserProfileFailure extends UserProfileState {
  final String error;
  UserProfileFailure({required this.error});
}
