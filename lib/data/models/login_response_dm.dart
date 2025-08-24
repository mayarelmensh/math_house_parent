import 'package:math_house_parent/domain/entities/login_response_entity.dart';

class LoginResponseDm extends LoginResponseEntity{
  LoginResponseDm({
      super.parent,
      super.token,
      this.errors
  });

  LoginResponseDm.fromJson(dynamic json) {
    parent = json['parent'] != null ? ParentLoginDm.fromJson(json['parent']) : null;
    token = json['token'];
  }
  String? errors;

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   if (parent != null) {
  //     map['parent'] = parent?.toJson();
  //   }
  //   map['token'] = token;
  //   return map;
  // }

}

class ParentLoginDm  extends ParentLoginEntity{
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
      super.students,});

  ParentLoginDm.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    code = json['code'];
    token = json['token'];
    role = json['role'];
    if (json['students'] != null) {
      students = [];
      json['students'].forEach((v) {
        students?.add(Students.fromJson(v));
      });
    }
  }
  // int? id;
  // String? name;
  // String? email;
  // String? phone;
  // String? createdAt;
  // String? updatedAt;
  // int? status;
  // dynamic code;
  // String? token;
  // String? role;
  // List<Students>? students;

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
      map['students'] =( students as List<Students>?)?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Students extends StudentsLoginEntity {
  Students({
      super.id,
      super.nickName,
      super.imageLink,
      super.pivot,});

  Students.fromJson(dynamic json) {
    id = json['id'];
    nickName = json['nick_name'];
    imageLink = json['image_link'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }
  // int? id;
  // String? nickName;
  // dynamic imageLink;
  // Pivot? pivot;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['nick_name'] = nickName;
    map['image_link'] = imageLink;
    if (pivot != null) {
      map['pivot'] = (pivot as Pivot?)?.toJson();
      }
    return map;
  }

}

class Pivot extends PivotLoginEntity {
  Pivot({
      super.parentId,
      super.userId,});

  Pivot.fromJson(dynamic json) {
    parentId = json['parent_id'];
    userId = json['user_id'];
  }
  // int? parentId;
  // int? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['parent_id'] = parentId;
    map['user_id'] = userId;
    return map;
  }

}