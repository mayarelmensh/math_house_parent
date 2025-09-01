import 'package:math_house_parent/domain/entities/login_response_entity.dart';

class LoginResponseDm extends LoginResponseEntity {
  LoginResponseDm({super.parent, super.token, this.errors});

  String? errors;

  factory LoginResponseDm.fromJson(Map<String, dynamic> json) {
    return LoginResponseDm(
      parent: json['parent'] != null
          ? ParentLoginDm.fromJson(json['parent'])
          : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (parent != null) {
      map['parent'] = (parent as ParentLoginDm).toJson();
    }
    map['token'] = token;
    return map;
  }

  factory LoginResponseDm.fromEntity(LoginResponseEntity entity) {
    return LoginResponseDm(
      parent: entity.parent != null
          ? ParentLoginDm.fromEntity(entity.parent!)
          : null,
      token: entity.token,
      errors: null,
    );
  }
}

class ParentLoginDm extends ParentLoginEntity {
  ParentLoginDm({
    super.id,
    super.name,
    super.email,
    super.phone,
    super.createdAt,
    super.updatedAt,
    super.status,
    super.code,
    super.token,
    super.role,
    super.students,
  });

  factory ParentLoginDm.fromJson(Map<String, dynamic> json) {
    return ParentLoginDm(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      status: json['status'],
      code: json['code'],
      token: json['token'],
      role: json['role'],
      students: json['students'] != null
          ? (json['students'] as List)
                .map((v) => StudentsDm.fromJson(v))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    map['code'] = code;
    map['token'] = token;
    map['role'] = role;
    if (students != null) {
      map['students'] = (students as List<StudentsDm>)
          .map((v) => v.toJson())
          .toList();
    }
    return map;
  }

  factory ParentLoginDm.fromEntity(ParentLoginEntity entity) {
    return ParentLoginDm(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
      code: entity.code,
      token: entity.token,
      role: entity.role,
      students: entity.students != null
          ? entity.students!.map((s) => StudentsDm.fromEntity(s)).toList()
          : null,
    );
  }
}

class StudentsDm extends StudentsLoginEntity {
  StudentsDm({super.id, super.nickName, super.imageLink, super.pivot});

  factory StudentsDm.fromJson(Map<String, dynamic> json) {
    return StudentsDm(
      id: json['id'],
      nickName: json['nick_name'],
      imageLink: json['image_link'],
      pivot: json['pivot'] != null ? PivotDm.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['nick_name'] = nickName;
    map['image_link'] = imageLink;
    if (pivot != null) {
      map['pivot'] = (pivot as PivotDm).toJson();
    }
    return map;
  }

  factory StudentsDm.fromEntity(StudentsLoginEntity entity) {
    return StudentsDm(
      id: entity.id,
      nickName: entity.nickName,
      imageLink: entity.imageLink,
      pivot: entity.pivot != null ? PivotDm.fromEntity(entity.pivot!) : null,
    );
  }
}

class PivotDm extends PivotLoginEntity {
  PivotDm({super.parentId, super.userId});

  factory PivotDm.fromJson(Map<String, dynamic> json) {
    return PivotDm(parentId: json['parent_id'], userId: json['user_id']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['parent_id'] = parentId;
    map['user_id'] = userId;
    return map;
  }

  factory PivotDm.fromEntity(PivotLoginEntity entity) {
    return PivotDm(parentId: entity.parentId, userId: entity.userId);
  }
}
