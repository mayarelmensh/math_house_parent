class RegisterResponseEntity {
  RegisterResponseEntity({
      this.parent, 
      this.token
  });

  ParentEntity? parent;
  String? token;


}

class ParentEntity {
  ParentEntity({
      this.name, 
      this.email, 
      this.phone, 
      this.updatedAt, 
      this.createdAt, 
      this.id, 
      this.token, 
      this.role,});

  String? name;
  String? email;
  String? phone;
  String? updatedAt;
  String? createdAt;
  int? id;
  String? token;
  String? role;


}