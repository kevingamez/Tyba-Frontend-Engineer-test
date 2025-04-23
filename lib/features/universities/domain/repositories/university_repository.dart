import 'package:university_app/features/universities/domain/entities/university.dart';

abstract class UniversityRepository {
  Future<List<University>> getUniversities();
}
