abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final Map<String, dynamic> data;
  RegisterSuccess({required this.data});
}

class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure({required this.error});
}
