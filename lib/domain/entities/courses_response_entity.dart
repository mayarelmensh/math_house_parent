class CoursesResponseEntity {
  CoursesResponseEntity({
      this.categories, 
      this.paymentMethods,});

  List<CategoriesEntity>? categories;
  List<PaymentMethodsEntity>? paymentMethods;


}

class PaymentMethodsEntity {
  PaymentMethodsEntity({
      this.id, 
      this.payment, 
      this.description, 
      this.logo, 
      this.statue, 
      this.createdAt, 
      this.updatedAt, 
      this.logoLink,});

  int? id;
  String? payment;
  String? description;
  String? logo;
  int? statue;
  String? createdAt;
  String? updatedAt;
  String? logoLink;


}

class CategoriesEntity {
  CategoriesEntity({
      this.id, 
      this.categoryName, 
      this.categoryDescription, 
      this.categoryImage, 
      this.teacher, 
      this.course,});

  int? id;
  String? categoryName;
  String? categoryDescription;
  String? categoryImage;
  dynamic teacher;
  List<CourseEntity>? course;


}

class CourseEntity {
  CourseEntity({
      this.id, 
      this.videosCount, 
      this.chaptersCount, 
      this.lessonsCount, 
      this.questionsCount, 
      this.quizsCount, 
      this.pdfsCount, 
      this.price, 
      this.allPrices, 
      this.courseName, 
      this.courseDescription, 
      this.courseImage, 
      this.teacher, 
      this.chapters,});

  int? id;
  int? videosCount;
  int? chaptersCount;
  int? lessonsCount;
  int? questionsCount;
  int? quizsCount;
  int? pdfsCount;
  int? price;
  List<AllPricesEntity>? allPrices;
  String? courseName;
  String? courseDescription;
  String? courseImage;
  dynamic teacher;
  List<ChaptersEntity>? chapters;


}

class ChaptersEntity {
  ChaptersEntity({
      this.id, 
      this.chapterPrice, 
      this.chapterAllPrices, 
      this.chapterName, 
      this.lessons,});

  int? id;
  int? chapterPrice;
  List<ChapterAllPricesEntity>? chapterAllPrices;
  String? chapterName;
  List<LessonsEntity>? lessons;


}

class LessonsEntity {
  LessonsEntity({
      this.id, 
      this.lessonName,});

  int? id;
  String? lessonName;


}

class ChapterAllPricesEntity {
  ChapterAllPricesEntity({
      this.id, 
      this.duration, 
      this.price, 
      this.discount, 
      this.chapterId, 
      this.createdAt, 
      this.updatedAt,});

  int? id;
  int? duration;
  int? price;
  int? discount;
  int? chapterId;
  String? createdAt;
  String? updatedAt;


}

class AllPricesEntity {
  AllPricesEntity({
      this.id, 
      this.courseId, 
      this.duration, 
      this.price, 
      this.discount, 
      this.createdAt, 
      this.updatedAt,});

  int? id;
  int? courseId;
  int? duration;
  int? price;
  int? discount;
  String? createdAt;
  String? updatedAt;


}