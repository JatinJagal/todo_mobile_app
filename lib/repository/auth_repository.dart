import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:todo_app/models/user_profile_model.dart';
import 'package:todo_app/services/api_services.dart';
import 'package:todo_app/services/local_storage_service.dart';
import 'package:todo_app/utils/endpoints.dart';
import 'package:todo_app/utils/global.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, Map<String, dynamic>>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
    File? imageFile,
  ) async {
    try {
      // Create FormData with fields
      // final formData = FormData.fromMap({
      //   'username': name,
      //   'useremail': email,
      //   'password': password,
      //   'confirmPassword': confirmPassword,
      //   'image': imageFile!.path,
      // }
      // );
      final formData = {
        'username': name,
        'useremail': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'image': imageFile!.path,
      };

      // Dio automatically sets Content-Type for FormData with proper boundary
      // Don't override it - just pass the FormData and let Dio handle it
      final response = await _apiService.post(
        Endpoints.register,
        formData,
        // Don't pass options - let Dio auto-detect FormData and set headers correctly
      );

      if (response.isRight) {
        if (response.right.statusCode == 201) {
          if (response.right.data != null) {
            LocalStorageService.i.setValueOnStorage(
              kToken,
              response.right.data['data']['token'],
            );
            return Right(response.right.data);
          }
        } else {
          final errorMessage =
              response.right.data?['message'] ?? 'An error occurred';
          return Left(errorMessage);
        }
      } else if (response.isLeft) {
        return Left(response.left);
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _apiService.post(Endpoints.login, {
        'useremail': email,
        'password': password,
      });
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            LocalStorageService.i.setValueOnStorage(
              kToken,
              response.right.data['data']['token'],
            );
            return Right(response.right.data);
          }
        }
      } else if (response.isLeft) {
        return Left(response.left);
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserProfileModel>> getUserProfile() async {
    try {
      final response = await _apiService.get(Endpoints.getProfile);
      if (response.isRight) {
        if (response.right.statusCode == 200) {
          if (response.right.data != null) {
            return Right(UserProfileModel.fromJson(response.right.data));
          }
        }
      } else if (response.isLeft) {
        return Left(response.left);
      }
      return Left('An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
