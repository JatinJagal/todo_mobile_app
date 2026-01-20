class ChatRequestModel {
  bool? success;
  String? message;
  ChatRequestDataWrapper? data;

  ChatRequestModel({this.success, this.message, this.data});

  ChatRequestModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = ChatRequestDataWrapper.fromJson(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ChatRequestDataWrapper {
  List<ChatRequestData>? sent;
  List<ChatRequestData>? received;
  int? total;

  ChatRequestDataWrapper({this.sent, this.received, this.total});

  ChatRequestDataWrapper.fromJson(Map<String, dynamic> json) {
    if (json['sent'] != null) {
      sent = <ChatRequestData>[];
      json['sent'].forEach((v) {
        sent!.add(ChatRequestData.fromJson(v));
      });
    }
    if (json['received'] != null) {
      received = <ChatRequestData>[];
      json['received'].forEach((v) {
        received!.add(ChatRequestData.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sent != null) {
      data['sent'] = sent!.map((v) => v.toJson()).toList();
    }
    if (received != null) {
      data['received'] = received!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}

class ChatRequestData {
  int? id;
  int? senderId;
  int? receiverId;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? senderUserId;
  String? senderUsername;
  String? senderEmail;
  String? senderImage;
  int? receiverUserId;
  String? receiverUsername;
  String? receiverEmail;
  String? receiverImage;

  ChatRequestData({
    this.id,
    this.senderId,
    this.receiverId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.senderUserId,
    this.senderUsername,
    this.senderEmail,
    this.senderImage,
    this.receiverUserId,
    this.receiverUsername,
    this.receiverEmail,
    this.receiverImage,
  });

  ChatRequestData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    // Handle nested sender object (for received requests)
    if (json['sender'] != null) {
      final sender = json['sender'] as Map<String, dynamic>;
      senderUserId = sender['id'];
      senderUsername = sender['username'];
      senderEmail = sender['useremail'];
      senderImage = sender['image'];
    } else {
      // Fallback to flat structure
      senderUserId = json['sender_user_id'];
      senderUsername = json['sender_username'];
      senderEmail = json['sender_email'];
      senderImage = json['sender_image'];
    }

    // Handle nested receiver object (for sent requests)
    if (json['receiver'] != null) {
      final receiver = json['receiver'] as Map<String, dynamic>;
      receiverUserId = receiver['id'];
      receiverUsername = receiver['username'];
      receiverEmail = receiver['useremail'];
      receiverImage = receiver['image'];
    } else {
      // Fallback to flat structure
      receiverUserId = json['receiver_user_id'];
      receiverUsername = json['receiver_username'];
      receiverEmail = json['receiver_email'];
      receiverImage = json['receiver_image'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['sender_user_id'] = senderUserId;
    data['sender_username'] = senderUsername;
    data['sender_email'] = senderEmail;
    data['sender_image'] = senderImage;
    data['receiver_user_id'] = receiverUserId;
    data['receiver_username'] = receiverUsername;
    data['receiver_email'] = receiverEmail;
    data['receiver_image'] = receiverImage;
    return data;
  }
}
