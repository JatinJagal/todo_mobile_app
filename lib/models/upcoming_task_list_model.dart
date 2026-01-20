class UpcomingTaskListModel {
  bool? success;
  String? message;
  DataUpcoming? data;

  UpcomingTaskListModel({this.success, this.message, this.data});

  UpcomingTaskListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? DataUpcoming.fromJson(json['data']) : null;
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

class DataUpcoming {
  List<UpComingTasks>? tasks;
  int? count;

  DataUpcoming({this.tasks, this.count});

  DataUpcoming.fromJson(Map<String, dynamic> json) {
    if (json['tasks'] != null) {
      tasks = <UpComingTasks>[];
      json['tasks'].forEach((v) {
        tasks!.add(UpComingTasks.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tasks != null) {
      data['tasks'] = tasks!.map((v) => v.toJson()).toList();
    }
    data['count'] = count;
    return data;
  }
}

class UpComingTasks {
  int? id;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? userEmail;
  String? createdAt;
  String? updatedAt;

  UpComingTasks({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.userEmail,
    this.createdAt,
    this.updatedAt,
  });

  UpComingTasks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    userEmail = json['user_email'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['user_email'] = userEmail;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
