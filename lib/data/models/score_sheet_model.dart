class ScoreSheetResponseModel {
  final List<Chapter> chapters;

  ScoreSheetResponseModel({required this.chapters});

  factory ScoreSheetResponseModel.fromJson(Map<String, dynamic> json) {
    return ScoreSheetResponseModel(
      chapters: (json['data'] as List)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Chapter {
  final int id;
  final String chapterName;
  final List<Lesson> lessons;

  Chapter({
    required this.id,
    required this.chapterName,
    required this.lessons,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      chapterName: json['chapter_name'] as String,
      lessons: (json['lessons'] as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lesson {
  final int id;
  final String lessonName;
  final int chapterId;
  final String liveAttend;
  final List<Quiz> quizzes;

  Lesson({
    required this.id,
    required this.lessonName,
    required this.chapterId,
    required this.liveAttend,
    required this.quizzes,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      lessonName: json['lesson_name'] as String,
      chapterId: json['chapter_id'] as int,
      liveAttend: json['live_attend'] as String,
      quizzes: (json['quizs'] as List)
          .map((e) => Quiz.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentScoreQuiz {
  final int score;
  final String time;
  final String date;

  StudentScoreQuiz({
    required this.score,
    required this.time,
    required this.date,
  });

  factory StudentScoreQuiz.fromJson(Map<String, dynamic> json) {
    return StudentScoreQuiz(
      score: json['score'] as int,
      time: json['time'] as String,
      date: json['date'] as String,
    );
  }
}

class Quiz {
  final int id;
  final String title;
  final int score;
  final int passScore;
  final int lessonId;
  final StudentScoreQuiz? studentScoreQuiz;

  Quiz({
    required this.id,
    required this.title,
    required this.score,
    required this.passScore,
    required this.lessonId,
    this.studentScoreQuiz,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      title: json['title'] as String,
      score: json['score'] as int,
      passScore: json['pass_score'] as int,
      lessonId: json['lesson_id'] as int,
      studentScoreQuiz: json['student_quizs'] != null &&
          (json['student_quizs'] as List).isNotEmpty
          ? StudentScoreQuiz.fromJson(
          (json['student_quizs'] as List).first as Map<String, dynamic>)
          : null,
    );
  }
}