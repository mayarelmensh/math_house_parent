class GetStudentsResponseEntity {
  GetStudentsResponseEntity({
      this.students,});

  List<StudentsEntity>? students;
}

class StudentsEntity {
  StudentsEntity({
      this.id, 
      this.email, 
      this.phone, 
      this.nickName, 
      this.imageLink,});

  int? id;
  String? email;
  String? phone;
  String? nickName;
  dynamic imageLink;


}