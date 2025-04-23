import 'package:flutter/material.dart';
import 'package:university_app/core/network/http_client.dart';
import 'package:university_app/features/universities/data/datasources/university_remote_datasource.dart';
import 'package:university_app/features/universities/data/repositories/university_repository_impl.dart';
import 'package:university_app/features/universities/domain/entities/university.dart';
import 'package:university_app/features/universities/domain/usecases/get_universities.dart';

class UniversitiesPage extends StatefulWidget {
  const UniversitiesPage({Key? key}) : super(key: key);

  @override
  State<UniversitiesPage> createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage> {
  late GetUniversities _getUniversities;
  List<University> _universities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Configuración manual de dependencias (en una app real usarías un sistema de DI)
    final httpClient = HttpClient();
    final remoteDatasource = UniversityRemoteDatasourceImpl(client: httpClient);
    final repository = UniversityRepositoryImpl(
      remoteDatasource: remoteDatasource,
    );
    _getUniversities = GetUniversities(repository);

    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final universities = await _getUniversities();
      setState(() {
        _universities = universities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universities')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUniversities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_universities.isEmpty) {
      return const Center(child: Text('No universities found'));
    }

    return RefreshIndicator(
      onRefresh: _loadUniversities,
      child: ListView.builder(
        itemCount: _universities.length,
        itemBuilder: (context, index) {
          final university = _universities[index];
          return ListTile(
            title: Text(university.name),
            subtitle: Text(university.country),
            trailing:
                university.webPages.isNotEmpty ? Icon(Icons.language) : null,
          );
        },
      ),
    );
  }
}
