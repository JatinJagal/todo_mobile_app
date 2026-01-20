class MessageModel {
  bool? success;
  String? message;
  MessageData? data;

  MessageModel({this.success, this.message, this.data});

  MessageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? MessageData.fromJson(json['data']) : null;
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

class MessageData {
  int? id;
  int? senderId;
  int? receiverId;
  String? message;
  int? isRead;
  String? createdAt;
  String? updatedAt;
  String? senderUsername;
  String? senderImage;
  String? receiverUsername;
  String? receiverImage;
  Sender? sender;
  Receiver? receiver;

  MessageData({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.isRead,
    this.createdAt,
    this.updatedAt,
    this.senderUsername,
    this.senderImage,
    this.receiverUsername,
    this.receiverImage,
    this.sender,
    this.receiver,
  });

  MessageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    message = json['message'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    senderUsername = json['sender_username'];
    senderImage = json['sender_image'];
    receiverUsername = json['receiver_username'];
    receiverImage = json['receiver_image'];
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    receiver =
        json['receiver'] != null ? Receiver.fromJson(json['receiver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['message'] = message;
    data['is_read'] = isRead;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['sender_username'] = senderUsername;
    data['sender_image'] = senderImage;
    data['receiver_username'] = receiverUsername;
    data['receiver_image'] = receiverImage;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    return data;
  }
}

class Sender {
  int? id;
  String? username;
  String? useremail;
  String? image;

  Sender({this.id, this.username, this.useremail, this.image});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    useremail = json['useremail'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['useremail'] = useremail;
    data['image'] = image;
    return data;
  }
}

class Receiver {
  int? id;
  String? username;
  String? useremail;
  String? image;

  Receiver({this.id, this.username, this.useremail, this.image});

  Receiver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    useremail = json['useremail'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['useremail'] = useremail;
    data['image'] = image;
    return data;
  }
}

class ConversationModel {
  bool? success;
  String? message;
  List<MessageData>? data;

  ConversationModel({this.success, this.message, this.data});

  ConversationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MessageData>[];
      json['data'].forEach((v) {
        data!.add(MessageData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

