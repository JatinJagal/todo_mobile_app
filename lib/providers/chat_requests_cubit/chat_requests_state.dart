import 'package:todo_app/models/chat_request_model.dart';

abstract class ChatRequestsState {}

class ChatRequestsInitial extends ChatRequestsState {}

class ChatRequestsLoading extends ChatRequestsState {}

class ChatRequestsSuccess extends ChatRequestsState {
  final List<ChatRequestData> requests;
  ChatRequestsSuccess({required this.requests});
}

class ChatRequestsFailure extends ChatRequestsState {
  final String error;
  ChatRequestsFailure({required this.error});
}

