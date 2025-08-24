class LoginResponseEntity {
  LoginResponseEntity({
      this.parent, 
      this.token,});

  ParentLoginEntity? parent;
  String? token;

}

class ParentLoginEntity {
  ParentLoginEntity({
      this.id, 
      this.name, 
      this.email, 
      this.phone, 
      this.createdAt, 
      this.updatedAt, 
      this.status, 
      this.code, 
      this.token, 
      this.role, 
      this.students,});

  int? id;
  String? name;
  String? email;
  String? phone;
  String? createdAt;
  String? updatedAt;
  int? status;
  dynamic code;
  String? token;
  String? role;
  List<StudentsLoginEntity>? students;


}

class StudentsLoginEntity {
  StudentsLoginEntity({
      this.id, 
      this.nickName, 
      this.imageLink, 
      this.pivot,});

  int? id;
  String? nickName;
  dynamic imageLink;
  PivotLoginEntity? pivot;


}

class PivotLoginEntity {
  PivotLoginEntity({
      this.parentId, 
      this.userId,});

  int? parentId;
  int? userId;


}