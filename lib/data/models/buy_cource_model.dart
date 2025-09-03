import 'package:math_house_parent/domain/entities/courses_response_entity.dart';

class BuyCourseResponseEntity {
  final CourseEntity? course;
  final String? paymentMethod;
  final int? price;

  BuyCourseResponseEntity({
    this.course,
    this.paymentMethod,
    this.price,
  });

  factory BuyCourseResponseEntity.fromJson(Map<String, dynamic> json) {
    return BuyCourseResponseEntity(
      course: json['course'] != null ? CourseEntity.fromJson(json['course']) : null,
      paymentMethod: json['payment_method']?.toString(),
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course?.toJson(),
      'payment_method': paymentMethod,
      'price': price,
    };
  }
}

// Reusing CourseEntity from courses_response_entity.dart
class CourseEntity {
  final int? id;
  final String? courseName;
  final int? categoryId;
  final String? courseDescription;
  final String? courseUrl;
  final String? preRequisition;
  final String? gain;
  final String? createdAt;
  final String? updatedAt;
  final int? teacherId;
  final int? userId;
  final String? type;
  final int? currencyId;
  final String? imageLink;
  final List<PriceEntity>? prices;

  CourseEntity({
    this.id,
    this.courseName,
    this.categoryId,
    this.courseDescription,
    this.courseUrl,
    this.preRequisition,
    this.gain,
    this.createdAt,
    this.updatedAt,
    this.teacherId,
    this.userId,
    this.type,
    this.currencyId,
    this.imageLink,
    this.prices,
  });

  factory CourseEntity.fromJson(Map<String, dynamic> json) {
    return CourseEntity(
      id: json['id'],
      courseName: json['course_name'],
      categoryId: json['category_id'],
      courseDescription: json['course_des'],
      courseUrl: json['course_url'],
      preRequisition: json['pre_requisition'],
      gain: json['gain'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      teacherId: json['teacher_id'],
      userId: json['user_id'],
      type: json['type'],
      currencyId: json['currancy_id'],
      imageLink: json['image_link'],
      prices: json['prices'] != null
          ? (json['prices'] as List).map((e) => PriceEntity.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'category_id': categoryId,
      'course_des': courseDescription,
      'course_url': courseUrl,
      'pre_requisition': preRequisition,
      'gain': gain,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'teacher_id': teacherId,
      'user_id': userId,
      'type': type,
      'currancy_id': currencyId,
      'image_link': imageLink,
      'prices': prices?.map((e) => e.toJson()).toList(),
    };
  }
}

class PriceEntity {
  final int? id;
  final int? courseId;
  final int? duration;
  final int? price;
  final int? discount;
  final String? createdAt;
  final String? updatedAt;

  PriceEntity({
    this.id,
    this.courseId,
    this.duration,
    this.price,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  factory PriceEntity.fromJson(Map<String, dynamic> json) {
    return PriceEntity(
      id: json['id'],
      courseId: json['course_id'],
      duration: json['duration'],
      price: json['price'],
      discount: json['discount'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'duration': duration,
      'price': price,
      'discount': discount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}