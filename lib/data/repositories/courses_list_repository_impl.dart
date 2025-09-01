import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/courses_response_entity.dart';
import 'package:math_house_parent/domain/repository/courses_list/courses_list_repository.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/courses_list_data_source.dart';
@Injectable(as: CoursesListRepository)
class CoursesListRepositoryImpl implements CoursesListRepository{
  CoursesListDataSource coursesListDataSource;
  CoursesListRepositoryImpl({required this.coursesListDataSource});
  @override
  Future<Either<Failures, CoursesResponseEntity>> getCoursesList()async {
  var either=await coursesListDataSource.getCoursesList();
  return either.fold((error)=>Left(error),
      (response)=>Right(response));
  }

}