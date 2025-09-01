class PackageEntity {
  final int id;
  final String name;
  final int courseId;
  final double price;
  final int number;
  final int duration;
  final String module;

  PackageEntity({
    required this.id,
    required this.name,
    required this.courseId,
    required this.price,
    required this.number,
    required this.duration,
    required this.module,
  });
}

class CourseEntity {
  final int id;
  final String courseName;
  final String? imageLink;
  final List<PackageEntity> packages;

  CourseEntity({
    required this.id,
    required this.courseName,
    this.imageLink,
    required this.packages,
  });
}

class PackagesResponseEntity {
  final CourseEntity courses;

  PackagesResponseEntity({
    required this.courses,
  });
}