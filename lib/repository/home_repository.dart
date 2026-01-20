import 'package:either_dart/either.dart';
import 'package:todo_app/models/tasks_model.dart';
import 'package:todo_app/models/upcoming_task_list_model.dart';
import 'package:todo_app/services/api_services.dart';
import 'package:todo_app/utils/endpoints.dart';

class HomeRepository {
  final ApiService _apiService = ApiService();
  Future<Either<String, List<Tasks>>> getTasks() async {
    try {
      final response = await _apiService.get(Endpoints.getTasks);
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            final data = TaskListModel.fromJson(response.right.data);
            return Right(data.data?.tasks ?? []);
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

  Future<Either<String, Map<String, dynamic>>> createTask({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await _apiService.post(Endpoints.createTask, {
        'title': title,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'start_time': startTime,
        'end_time': endTime,
      });
      if (response.isRight) {
        if (response.right.statusCode == 201) {
          if (response.right.data != null) {
            return Right(response.right.data);
          }
        } else {
          // If status code is not 201, return error message
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

  Future<Either<String, List<UpComingTasks>>> getUpcomingTasks() async {
    try {
      final response = await _apiService.get(Endpoints.getUpcomingTasks);
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            final data = UpcomingTaskListModel.fromJson(response.right.data);
            return Right(data.data?.tasks ?? []);
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
}
