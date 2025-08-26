import '../../domain/entities/confirm_code_response_entity.dart';

class ConfirmCodeDm extends ConfirmCodeResponseEntity {
 ConfirmCodeDm({super.errorMessage,super.successMessage});

  factory ConfirmCodeDm.fromJson(Map<String, dynamic> json) {
    return ConfirmCodeDm(
      successMessage: json['success'] as String?,
      errorMessage: json['errors'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': successMessage,
      'errors': errorMessage,
    };
  }
}


