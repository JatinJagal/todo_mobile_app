import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/chat_requests_cubit/chat_requests_state.dart';
import 'package:todo_app/repository/users_activity_repository.dart';

class ChatRequestsCubit extends Cubit<ChatRequestsState> {
  final UsersActivityRepository usersActivityRepository;
  ChatRequestsCubit(this.usersActivityRepository)
      : super(ChatRequestsInitial());

  Future<void> getChatRequests() async {
    emit(ChatRequestsLoading());
    final result = await usersActivityRepository.getChatRequests();
    result.either(
      (left) {
        emit(ChatRequestsFailure(error: left));
      },
      (right) {
        emit(ChatRequestsSuccess(requests: right));
      },
    );
  }
}

