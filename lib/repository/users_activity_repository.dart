import 'package:either_dart/either.dart';
import 'package:todo_app/models/chat_request_model.dart';
import 'package:todo_app/models/list_users_model.dart';
import 'package:todo_app/models/message_model.dart';
import 'package:todo_app/services/api_services.dart';
import 'package:todo_app/utils/endpoints.dart';

class UsersActivityRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, List<ListUsersModel>>> getAllUsersList() async {
    try {
      final response = await _apiService.get(Endpoints.getAllUsersList);
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            final usersList = response.right.data['data']['users'] as List;
            final data = List<ListUsersModel>.from(
              usersList.map(
                (e) => ListUsersModel.fromJson(e as Map<String, dynamic>),
              ),
            );
            return Right(data);
          }
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> sendChatRequestToUser(
    int id,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.sentChatRequest, {
        "receiverId": id,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200 ||
            response.right.statusCode == 201) {
          if (response.right.data != null) {
            return Right(response.right.data);
          }
        } else {
          // If status code is not 200/201, return error message
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ChatRequestData>>> getChatRequests() async {
    try {
      final response = await _apiService.get(Endpoints.getChatRequest);
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            final model = ChatRequestModel.fromJson(response.right.data);
            // Combine sent and received requests into a single list
            final List<ChatRequestData> allRequests = [];
            if (model.data?.sent != null) {
              allRequests.addAll(model.data!.sent!);
            }
            if (model.data?.received != null) {
              allRequests.addAll(model.data!.received!);
            }
            return Right(allRequests);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> acceptChatRequest(
    int requestId,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.acceptChatRequest, {
        "requestId": requestId,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200 ||
            response.right.statusCode == 201) {
          if (response.right.data != null) {
            return Right(response.right.data);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> rejectChatRequest(
    int requestId,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.rejectChatRequest, {
        "requestId": requestId,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200 ||
            response.right.statusCode == 201) {
          if (response.right.data != null) {
            return Right(response.right.data);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> removeChatRequest(
    int requestId,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.removeChatRequest, {
        "requestId": requestId,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200 ||
            response.right.statusCode == 201) {
          if (response.right.data != null) {
            return Right(response.right.data);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, MessageData>> sendMessage(
    int receiverId,
    String message,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.sendMessage, {
        "receiverId": receiverId,
        "message": message,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200 ||
            response.right.statusCode == 201) {
          if (response.right.data != null) {
            final data = MessageModel.fromJson(response.right.data);
            return Right(data.data!);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<MessageData>>> getConversation(
    int receiverId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.getConversation}/$receiverId?limit=$limit&offset=$offset',
      );
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            final data = ConversationModel.fromJson(response.right.data);
            return Right(data.data ?? []);
          }
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> markMessageRead(
    int senderId,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.markMessageRead, {
        "senderId": senderId,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200 ||
            response.right.statusCode == 201) {
          if (response.right.data != null) {
            return Right(response.right.data);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left.toString());
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
