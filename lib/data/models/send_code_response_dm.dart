
import '../../domain/entities/send_code_response_entity.dart';

class SendCodeResponseDm extends SendCodeResponseEntity {
   SendCodeResponseDm({
    super.errors,super.successMessage
  });

  factory SendCodeResponseDm.fromJson(Map<String, dynamic> json) {
    return SendCodeResponseDm(
      successMessage: json['success'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
        json['errors'].map(
              (key, value) => MapEntry(
            key,
            List<String>.from(value),
          ),
        ),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': successMessage,
      'errors': errors,
    };
  }
}
