import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/chat_request_action_cubit/chat_request_action_state.dart';
import 'package:todo_app/repository/users_activity_repository.dart';

class ChatRequestActionCubit extends Cubit<ChatRequestActionState> {
  final UsersActivityRepository usersActivityRepository;
  ChatRequestActionCubit(this.usersActivityRepository)
      : super(ChatRequestActionInitial());

  Future<void> acceptChatRequest(int requestId) async {
    emit(ChatRequestActionLoading(requestId: requestId));
    final result = await usersActivityRepository.acceptChatRequest(requestId);
    result.either(
      (left) {
        emit(ChatRequestActionFailure(error: left, requestId: requestId));
      },
      (right) {
        emit(ChatRequestActionSuccess(
          data: right,
          requestId: requestId,
          action: 'accept',
        ));
      },
    );
  }

  Future<void> rejectChatRequest(int requestId) async {
    emit(ChatRequestActionLoading(requestId: requestId));
    final result = await usersActivityRepository.rejectChatRequest(requestId);
    result.either(
      (left) {
        emit(ChatRequestActionFailure(error: left, requestId: requestId));
      },
      (right) {
        emit(ChatRequestActionSuccess(
          data: right,
          requestId: requestId,
          action: 'reject',
        ));
      },
    );
  }

  Future<void> removeChatRequest(int requestId) async {
    emit(ChatRequestActionLoading(requestId: requestId));
    final result = await usersActivityRepository.removeChatRequest(requestId);
    result.either(
      (left) {
        emit(ChatRequestActionFailure(error: left, requestId: requestId));
      },
      (right) {
        emit(ChatRequestActionSuccess(
          data: right,
          requestId: requestId,
          action: 'remove',
        ));
      },
    );
  }
}

