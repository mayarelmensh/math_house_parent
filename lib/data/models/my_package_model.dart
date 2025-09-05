class MyPackageModel {
  final int? exams;
  final int? questions;
  final int? lives;

  MyPackageModel({
    this.exams,
    this.questions,
    this.lives,
  });

  factory MyPackageModel.fromJson(Map<String, dynamic> json) {
    return MyPackageModel(
      exams: json['exams'] is int ? json['exams'] : int.tryParse(json['exams'].toString() ?? '0'),
      questions: json['questions'] is int ? json['questions'] : int.tryParse(json['questions'].toString() ?? '0'),
      lives: json['lives'] is int ? json['lives'] : int.tryParse(json['lives'].toString() ?? '0'),
    );
  }
}