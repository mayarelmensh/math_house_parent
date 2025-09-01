
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/data/models/login_response_dm.dart';
import 'package:math_house_parent/data/models/register_response_dm.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/auth_data_source.dart';
@Injectable(as: AuthDataSource)
class AuthRemoteDataSourceImpl implements AuthDataSource {
  ApiManager apiManager;
  AuthRemoteDataSourceImpl({required this.apiManager});

  @override
  Future<Either<Failures, RegisterResponseDm>> register(
      String name,
      String email,
      String phone,
      String password,
      String confPassword,
      ) async {
    try {
      var response = await apiManager.postData(
        endPoint: EndPoints.signUp,
        body: {
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "conf_password": confPassword
        },
      );

      // Success case (200 status code)
      if (response.statusCode == 200) {
        var registerResponse = RegisterResponseDm.fromJson(response.data);
        return Right(registerResponse);
      }

      // Validation errors (422 status code - duplicate email, etc.)
      else if (response.statusCode == 400|| response.statusCode == 422) {
        // Extract the error message from the response
        String errorMessage = "Validation failed";
        if (response.data != null && response.data['errors'] != null) {
          var errors = response.data['errors'];
          List<String> errorMessages = [];
          // Extract all error messages
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            }
          });
          errorMessage = errorMessages.join(', ');
        }
        return Left(ValidationFailure(errorMsg: errorMessage));
      }

      // Other server errors (4xx, 5xx)
      else {
        String errorMessage = "Server error occurred";
        // Try to extract error message from response if available
        if (response.data != null && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        return Left(ServerError(errorMsg: errorMessage));
      }
    } catch (e) {
      // Network errors, parsing errors, etc.
      return Left(NetworkError(errorMsg: "Network error: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failures, LoginResponseDm>> login(
      String email, String password) async {
    try{
      var response= await apiManager.postData(endPoint: EndPoints.signIn,
      queryParameters: {
        "email":email,
        "password": password
      },
    );
    if(response.statusCode==200){
      var loginResponse=LoginResponseDm.fromJson(response.data);
      return Right(loginResponse);
    }

    else if (response.statusCode == 400|| response.statusCode == 422) {
      // Extract the error message from the response
      String errorMessage = "Validation failed";
      if (response.data != null && response.data['errors'] != null) {
        var errors = response.data['errors'];
        List<String> errorMessages = [];
        // Extract all error messages
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.cast<String>());
          }
        });
        errorMessage = errorMessages.join(', ');
      }
      return Left(ValidationFailure(errorMsg: errorMessage));
    }

    // Other server errors (4xx, 5xx)
    else {
      String errorMessage = "Server error occurred";

      // Try to extract error message from response if available
      if (response.data != null && response.data['message'] != null) {
        errorMessage = response.data['message'];
      }

      return Left(ServerError(errorMsg: errorMessage));
    }
    } catch (e) {
      // Network errors, parsing errors, etc.
      return Left(NetworkError(errorMsg: "Network error: ${e.toString()}"));
    }
  }
   }
