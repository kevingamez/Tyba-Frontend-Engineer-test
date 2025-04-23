import 'package:university_app/core/network/http_client.dart';
import 'package:university_app/features/universities/data/models/university_model.dart';

abstract class UniversityRemoteDatasource {
  Future<List<UniversityModel>> getUniversities();
}

class UniversityRemoteDatasourceImpl implements UniversityRemoteDatasource {
  final HttpClient client;
  final String universitiesUrl =
      'https://tyba-assets.s3.amazonaws.com/FE-Engineer-test/universities.json';

  UniversityRemoteDatasourceImpl({required this.client});

  @override
  Future<List<UniversityModel>> getUniversities() async {
    final jsonData = await client.get(universitiesUrl);
    return (jsonData as List)
        .map((university) => UniversityModel.fromJson(university))
        .toList();
  }
}
