class ChapterDataEntity {
  final int videos;
  final int chapters;
  final int lessons;
  final int questions;
  final int quizzes;
  final int pdfs;

  ChapterDataEntity({
    required this.videos,
    required this.chapters,
    required this.lessons,
    required this.questions,
    required this.quizzes,
    required this.pdfs,
  });

  factory ChapterDataEntity.fromJson(Map<String, dynamic> json) {
    return ChapterDataEntity(
      videos: json['videos'] ?? 0,
      chapters: json['chapters'] ?? 0,
      lessons: json['lessons'] ?? 0,
      questions: json['questions'] ?? 0,
      quizzes: json['quizs'] ?? 0,
      pdfs: json['pdfs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videos': videos,
      'chapters': chapters,
      'lessons': lessons,
      'questions': questions,
      'quizs': quizzes,
      'pdfs': pdfs,
    };
  }
}