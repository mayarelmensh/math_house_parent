class MyCoursesModel {
  final int id;
  final String courseName;
  final String courseDescription;
  final String? image;
  final List<Chapter> chapters;

  MyCoursesModel({
    required this.id,
    required this.courseName,
    required this.courseDescription,
    this.image,
    required this.chapters,
  });

  factory MyCoursesModel.fromJson(Map<String, dynamic> json) {
    return MyCoursesModel(
      id: json['id'],
      courseName: json['course_name'],
      courseDescription: json['course_des'],
      image: json['image'],
      chapters: (json['chapters'] as List)
          .map((chapterJson) => Chapter.fromJson(chapterJson))
          .toList(),
    );
  }
}

class Chapter {
  final int id;
  final String chapterName;
  final String? image;

  Chapter({required this.id, required this.chapterName, this.image});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterName: json['chapter_name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_name': chapterName,
      'image': image,
    };
  }
}
