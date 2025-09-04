class CourseForScoreSheetModel {
  final int id;
  final String courseName;
  final String? imageLink;

  CourseForScoreSheetModel({
    required this.id,
    required this.courseName,
    this.imageLink,
  });

  factory CourseForScoreSheetModel.fromJson(Map<String, dynamic> json) {
    return CourseForScoreSheetModel(
      id: json['id'] as int,
      courseName: json['course_name'] as String,
      imageLink: json['image_link'] as String?,
    );
  }
}

class CoursesResponse {
  final List<CourseForScoreSheetModel> courses;

  CoursesResponse({required this.courses});

  factory CoursesResponse.fromJson(Map<String, dynamic> json) {
    return CoursesResponse(
      courses: (json['courses'] as List)
          .map((e) => CourseForScoreSheetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}