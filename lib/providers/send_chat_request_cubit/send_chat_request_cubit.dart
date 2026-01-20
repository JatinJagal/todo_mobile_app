import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/send_chat_request_cubit/send_chat_request_state.dart';
import 'package:todo_app/repository/users_activity_repository.dart';

class SendChatRequestCubit extends Cubit<SendChatRequestState> {
  final UsersActivityRepository usersActivityRepository;
  SendChatRequestCubit(this.usersActivityRepository)
      : super(SendChatRequestInitial());

  Future<void> sendChatRequest(int receiverId) async {
    emit(SendChatRequestLoading(receiverId: receiverId));
    final result = await usersActivityRepository.sendChatRequestToUser(receiverId);
    result.either(
      (left) {
        emit(SendChatRequestFailure(error: left, receiverId: receiverId));
      },
      (right) {
        emit(SendChatRequestSuccess(data: right, receiverId: receiverId));
      },
    );
  }
}

