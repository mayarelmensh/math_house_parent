class BuyChapterModel {
  final String? price;
  final String? paymentMethod;
  final List<ChapterModel>? chapters;

  BuyChapterModel({
    this.price,
    this.paymentMethod,
    this.chapters,
  });

  BuyChapterModel.fromJson(Map<String, dynamic> json)
      : price = json['price']?.toString(),
        paymentMethod = json['p_method'],
        chapters = (json['chapters'] as List<dynamic>?)
            ?.map((v) => ChapterModel.fromJson(v))
            .toList();

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'p_method': paymentMethod,
      'chapters': chapters?.map((v) => v.toJson()).toList(),
    };
  }
}

class ChapterModel {
  final int? id;
  final String? chapterName;
  final int? courseId;
  final int? currencyId;
  final String? description;
  final String? chapterUrl;
  final String? preRequisition;
  final String? gain;
  final int? teacherId;
  final String? createdAt;
  final String? updatedAt;
  final String? type;
  final String? duration;
  final List<ChapterPriceModel>? prices;

  ChapterModel({
    this.id,
    this.chapterName,
    this.courseId,
    this.currencyId,
    this.description,
    this.chapterUrl,
    this.preRequisition,
    this.gain,
    this.teacherId,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.duration,
    this.prices,
  });

  ChapterModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        chapterName = json['chapter_name'],
        courseId = json['course_id'],
        currencyId = json['currancy_id'],
        description = json['ch_des'],
        chapterUrl = json['ch_url'],
        preRequisition = json['pre_requisition'],
        gain = json['gain'],
        teacherId = json['teacher_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        type = json['type'],
        duration = json['duration'],
        prices = (json['price'] as List<dynamic>?)
            ?.map((v) => ChapterPriceModel.fromJson(v))
            .toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_name': chapterName,
      'course_id': courseId,
      'currancy_id': currencyId,
      'ch_des': description,
      'ch_url': chapterUrl,
      'pre_requisition': preRequisition,
      'gain': gain,
      'teacher_id': teacherId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      'duration': duration,
      'price': prices?.map((v) => v.toJson()).toList(),
    };
  }
}

class ChapterPriceModel {
  final int? id;
  final int? duration;
  final int? price;
  final int? discount;
  final int? chapterId;
  final String? createdAt;
  final String? updatedAt;

  ChapterPriceModel({
    this.id,
    this.duration,
    this.price,
    this.discount,
    this.chapterId,
    this.createdAt,
    this.updatedAt,
  });

  ChapterPriceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        duration = json['duration'],
        price = json['price'],
        discount = json['discount'],
        chapterId = json['chapter_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration,
      'price': price,
      'discount': discount,
      'chapter_id': chapterId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}