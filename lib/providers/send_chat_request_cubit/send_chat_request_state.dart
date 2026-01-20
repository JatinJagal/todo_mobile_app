abstract class SendChatRequestState {}

class SendChatRequestInitial extends SendChatRequestState {}

class SendChatRequestLoading extends SendChatRequestState {
  final int? receiverId;
  SendChatRequestLoading({this.receiverId});
}

class SendChatRequestSuccess extends SendChatRequestState {
  final Map<String, dynamic> data;
  final int? receiverId;
  SendChatRequestSuccess({required this.data, this.receiverId});
}

class SendChatRequestFailure extends SendChatRequestState {
  final String error;
  final int? receiverId;
  SendChatRequestFailure({required this.error, this.receiverId});
}

