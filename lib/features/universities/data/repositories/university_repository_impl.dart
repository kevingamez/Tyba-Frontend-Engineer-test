import 'package:university_app/features/universities/data/datasources/university_remote_datasource.dart';
import 'package:university_app/features/universities/domain/entities/university.dart';
import 'package:university_app/features/universities/domain/repositories/university_repository.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  final UniversityRemoteDatasource remoteDatasource;

  UniversityRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<University>> getUniversities() async {
    final universities = await remoteDatasource.getUniversities();
    return universities
        .map(
          (model) => University(
            name: model.name,
            country: model.country,
            domains: model.domains,
            alphaTwoCode: model.alphaTwoCode,
            stateProvince: model.stateProvince,
            webPages: model.webPages,
          ),
        )
        .toList();
  }
}
