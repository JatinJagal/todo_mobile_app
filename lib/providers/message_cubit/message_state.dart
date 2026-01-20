import 'package:todo_app/models/message_model.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageSuccess extends MessageState {
  final MessageData message;
  MessageSuccess({required this.message});
}

class MessageFailure extends MessageState {
  final String error;
  MessageFailure({required this.error});
}

// Conversation States
abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationSuccess extends ConversationState {
  final List<MessageData> messages;
  ConversationSuccess({required this.messages});
}

class ConversationFailure extends ConversationState {
  final String error;
  ConversationFailure({required this.error});
}

class ConversationMessageReceived extends ConversationState {
  final MessageData message;
  ConversationMessageReceived({required this.message});
}

// Mark Read States
abstract class MarkReadState {}

class MarkReadInitial extends MarkReadState {}

class MarkReadLoading extends MarkReadState {
  final int senderId;
  MarkReadLoading({required this.senderId});
}

class MarkReadSuccess extends MarkReadState {
  final Map<String, dynamic> data;
  final int senderId;
  MarkReadSuccess({required this.data, required this.senderId});
}

class MarkReadFailure extends MarkReadState {
  final String error;
  final int senderId;
  MarkReadFailure({required this.error, required this.senderId});
}

