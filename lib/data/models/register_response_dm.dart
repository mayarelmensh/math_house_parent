import 'package:math_house_parent/domain/entities/register_response_entity.dart';

class RegisterResponseDm extends RegisterResponseEntity{
  RegisterResponseDm({
      super.parent,
      super.token,
      this.errors
  });

  RegisterResponseDm.fromJson(dynamic json) {
    parent = json['parent'] != null ? ParentDm.fromJson(json['parent']) : null;
    token = json['token'];
    errors = json['errors'];
  }

  dynamic errors;

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   if (parent != null) {
  //     map['parent'] = parent?.toJson();
  //   }
  //   map['token'] = token;
  //   return map;
  // }

}

class ParentDm extends ParentEntity  {
  ParentDm({
      super.name,
      super.email,
      super.phone,
      super.updatedAt,
      super.createdAt,
      super.id,
      super.token,
      super.role,});

  ParentDm.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    token = json['token'];
    role = json['role'];
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['updated_at'] = updatedAt;
    map['created_at'] = createdAt;
    map['id'] = id;
    map['token'] = token;
    map['role'] = role;
    return map;
  }

}