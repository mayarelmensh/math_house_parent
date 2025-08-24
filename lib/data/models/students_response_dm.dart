import '../../domain/entities/get_students_response_entity.dart';

class StudentsResponseDm extends GetStudentsResponseEntity{
  StudentsResponseDm({
      super.students,});

  StudentsResponseDm.fromJson(dynamic json) {
    if (json['students'] != null) {
      students = [];
      json['students'].forEach((v) {
        students?.add(StudentsDm.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   if (students != null) {
  //     map['students'] = students?.map((v) => v.toJson()).toList();
  //   }
  //   return map;
  // }

}

class StudentsDm extends StudentsEntity {
  StudentsDm({
      super.id,
      super.email,
      super.phone,
      super.nickName,
      super.imageLink,});

  StudentsDm.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    phone = json['phone'];
    nickName = json['nick_name'];
    imageLink = json['image_link'];
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['phone'] = phone;
    map['nick_name'] = nickName;
    map['image_link'] = imageLink;
    return map;
  }

}