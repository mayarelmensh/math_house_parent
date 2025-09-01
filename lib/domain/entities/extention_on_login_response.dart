import 'login_response_entity.dart';

extension ParentLoginEntityCopyWith on ParentLoginEntity {
  ParentLoginEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? createdAt,
    String? updatedAt,
    int? status,
    dynamic code,
    String? token,
    String? role,
    List<StudentsLoginEntity>? students,
  }) {
    return ParentLoginEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      code: code ?? this.code,
      token: token ?? this.token,
      role: role ?? this.role,
      students: students ?? this.students,
    );
  }
}
