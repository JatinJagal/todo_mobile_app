class ListUsersModel {
  int? id;
  String? username;
  String? useremail;
  String? image;
  String? createdAt;
  String? status;
  int? senderId;
  int? receiverId;

  ListUsersModel({
    this.id,
    this.username,
    this.useremail,
    this.image,
    this.createdAt,
    this.status,
    this.senderId,
    this.receiverId,
  });

  ListUsersModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    useremail = json['useremail'];
    image = json['image'];
    createdAt = json['created_at'];
    status = json['status'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['useremail'] = useremail;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['status'] = status;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    return data;
  }
}
