import '../../domain/entities/packages_response_entity.dart';

class PackageDm extends PackageEntity {
  PackageDm({
    required int id,
    required String name,
    required int courseId,
    required double price,
    required int number,
    required int duration,
    required String module,
  }) : super(
    id: id,
    name: name,
    courseId: courseId,
    price: price,
    number: number,
    duration: duration,
    module: module,
  );

  factory PackageDm.fromJson(Map<String, dynamic> json) {
    return PackageDm(
      id: json['id'],
      name: json['name'],
      courseId: json['course_id'],
      price: (json['price'] as num).toDouble(),
      number: json['number'],
      duration: json['duration'],
      module: json['module'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'course_id': courseId,
    'price': price,
    'number': number,
    'duration': duration,
    'module': module,
  };
}

class CourseDm extends CourseEntity {
  CourseDm({
    required int id,
    required String courseName,
    String? imageLink,
    required List<PackageDm> packages,
  }) : super(
    id: id,
    courseName: courseName,
    imageLink: imageLink,
    packages: packages,
  );

  factory CourseDm.fromJson(Map<String, dynamic> json) {
    var packagesList = <PackageDm>[];
    if (json['packages'] != null) {
      packagesList = List<Map<String, dynamic>>.from(json['packages'])
          .map((pkgJson) => PackageDm.fromJson(pkgJson))
          .toList();
    }
    return CourseDm(
      id: json['id'],
      courseName: json['course_name'],
      imageLink: json['image_link'],
      packages: packagesList,
    );
  }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'course_name': courseName,
  //   'image_link': imageLink,
  //   'packages': packages.map((pkg) => pkg.toJson()).toList(),
  // };
}

class PackagesResponseDm extends PackagesResponseEntity {
  PackagesResponseDm({
    required CourseDm courses,
  }) : super(courses: courses);

  factory PackagesResponseDm.fromJson(Map<String, dynamic> json) {
    return PackagesResponseDm(
      courses: CourseDm.fromJson(json['courses']),
    );
  }

  // Map<String, dynamic> toJson() => {
  //   'courses': courses.toJson(),
  // };
}