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
  bool _isGridView = false; // Por defecto empezamos con ListView

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

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universities'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Show as list' : 'Show as grid',
          ),
        ],
      ),
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
      child: _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _universities.length,
      itemBuilder: (context, index) {
        final university = _universities[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(university.name),
            subtitle: Text(university.country),
            trailing:
                university.webPages.isNotEmpty
                    ? const Icon(Icons.language)
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _universities.length,
      itemBuilder: (context, index) {
        final university = _universities[index];
        return Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 40),
                const SizedBox(height: 8),
                Text(
                  university.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  university.country,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                if (university.webPages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Icon(Icons.language, size: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
