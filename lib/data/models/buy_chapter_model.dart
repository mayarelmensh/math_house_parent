class BuyChapterModel {
  final int? price;
  final dynamic paymentMethod;
  final List<Chapter>? chapters;

  BuyChapterModel({
    this.price,
    this.paymentMethod,
    this.chapters,
  });

  factory BuyChapterModel.fromJson(Map<String, dynamic> json) {
    return BuyChapterModel(
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()),
      paymentMethod: json['p_method'],
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Chapter {
  final int? id;
  final String? chapterName;
  final int? courseId;
  final int? currancyId;
  final String? chDes;
  final String? chUrl;
  final String? preRequisition;
  final String? gain;
  final int? teacherId;
  final String? createdAt;
  final String? updatedAt;
  final String? type;
  final int? duration;
  final List<ChapterPrice>? price;

  Chapter({
    this.id,
    this.chapterName,
    this.courseId,
    this.currancyId,
    this.chDes,
    this.chUrl,
    this.preRequisition,
    this.gain,
    this.teacherId,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.duration,
    this.price,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterName: json['chapter_name']?.toString(),
      courseId: json['course_id'],
      currancyId: json['currancy_id'],
      chDes: json['ch_des']?.toString(),
      chUrl: json['ch_url']?.toString(),
      preRequisition: json['pre_requisition']?.toString(),
      gain: json['gain']?.toString(),
      teacherId: json['teacher_id'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      type: json['type']?.toString(),
      duration: json['duration'],
      price: (json['price'] as List<dynamic>?)
          ?.map((e) => ChapterPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterPrice {
  final int? id;
  final int? duration;
  final int? price;
  final int? discount;
  final int? chapterId;
  final String? createdAt;
  final String? updatedAt;

  ChapterPrice({
    this.id,
    this.duration,
    this.price,
    this.discount,
    this.chapterId,
    this.createdAt,
    this.updatedAt,
  });

  factory ChapterPrice.fromJson(Map<String, dynamic> json) {
    return ChapterPrice(
      id: json['id'],
      duration: json['duration'],
      price: json['price'], // int
      discount: json['discount'],
      chapterId: json['chapter_id'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
