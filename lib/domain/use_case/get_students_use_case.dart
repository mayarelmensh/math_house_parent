import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/get_students_response_entity.dart';
import '../repository/getStudents/get_students_repository.dart';
@injectable
class GetStudentsUseCase {
  final GetStudentsRepository repository;

  GetStudentsUseCase(this.repository);

  Future<Either<Failures, List<StudentsEntity>>> invoke([String? query]) async {
    final result = await repository.getStudents();

    return result.map((students) {
      if (query == null || query.isEmpty) {
        return students;
      }
      final q = query.toLowerCase();
      return students.where((s) {
        return s.nickName?.toLowerCase().contains(q) == true ||
            s.email?.toLowerCase().contains(q) == true;
      }).toList();
    });
  }
}

