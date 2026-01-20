abstract class ChatRequestActionState {}

class ChatRequestActionInitial extends ChatRequestActionState {}

class ChatRequestActionLoading extends ChatRequestActionState {
  final int requestId;
  ChatRequestActionLoading({required this.requestId});
}

class ChatRequestActionSuccess extends ChatRequestActionState {
  final Map<String, dynamic> data;
  final int requestId;
  final String action; // 'accept', 'reject', or 'remove'
  ChatRequestActionSuccess({
    required this.data,
    required this.requestId,
    required this.action,
  });
}

class ChatRequestActionFailure extends ChatRequestActionState {
  final String error;
  final int requestId;
  ChatRequestActionFailure({required this.error, required this.requestId});
}

