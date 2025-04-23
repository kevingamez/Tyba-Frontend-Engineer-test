import 'package:university_app/features/universities/domain/entities/university.dart';
import 'package:university_app/features/universities/domain/repositories/university_repository.dart';

class GetUniversities {
  final UniversityRepository repository;

  GetUniversities(this.repository);

  Future<List<University>> call() async {
    return await repository.getUniversities();
  }
}
