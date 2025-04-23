import 'package:flutter/material.dart';
import 'package:university_app/core/network/http_client.dart';
import 'package:university_app/features/universities/data/datasources/university_remote_datasource.dart';
import 'package:university_app/features/universities/data/repositories/university_repository_impl.dart';
import 'package:university_app/features/universities/domain/entities/university.dart';
import 'package:university_app/features/universities/domain/usecases/get_universities.dart';
import 'package:university_app/features/universities/presentation/pages/university_detail_page.dart';

class UniversitiesPage extends StatefulWidget {
  const UniversitiesPage({Key? key}) : super(key: key);

  @override
  State<UniversitiesPage> createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage> {
  late GetUniversities _getUniversities;
  List<University> _allUniversities = [];
  List<University> _displayedUniversities = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  bool _isGridView = false;

  // Infinite scroll parameters
  final int _itemsPerPage = 20;
  int _currentPage = 0;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Configuración manual de dependencias
    final httpClient = HttpClient();
    final remoteDatasource = UniversityRemoteDatasourceImpl(client: httpClient);
    final repository = UniversityRepositoryImpl(
      remoteDatasource: remoteDatasource,
    );
    _getUniversities = GetUniversities(repository);

    // Setup scroll controller for infinite scrolling
    _scrollController.addListener(_scrollListener);

    _loadUniversities();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreUniversities();
      }
    }
  }

  Future<void> _loadUniversities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final universities = await _getUniversities();

      setState(() {
        _allUniversities = universities;
        _displayedUniversities = universities.take(_itemsPerPage).toList();
        _currentPage = 1;
        _hasMoreData = universities.length > _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreUniversities() async {
    if (!_hasMoreData || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulamos una carga con delay para mostrar el efecto de carga
    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final moreItems =
        _allUniversities.length > endIndex
            ? _allUniversities.sublist(startIndex, endIndex)
            : _allUniversities.sublist(startIndex);

    setState(() {
      _displayedUniversities.addAll(moreItems);
      _currentPage++;
      _hasMoreData = endIndex < _allUniversities.length;
      _isLoadingMore = false;
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _navigateToDetail(University university) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UniversityDetailPage(university: university),
      ),
    );
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

    if (_displayedUniversities.isEmpty) {
      return const Center(child: Text('No universities found'));
    }

    return RefreshIndicator(
      onRefresh: _loadUniversities,
      child: _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _displayedUniversities.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Si estamos al final y hay más datos, mostramos el indicador de carga
        if (index == _displayedUniversities.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final university = _displayedUniversities[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(university.name),
            subtitle: Text(university.country),
            trailing:
                university.webPages.isNotEmpty
                    ? const Icon(Icons.language)
                    : null,
            onTap: () => _navigateToDetail(university),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _displayedUniversities.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Si estamos al final y hay más datos, mostramos el indicador de carga
        if (index == _displayedUniversities.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final university = _displayedUniversities[index];
        return GestureDetector(
          onTap: () => _navigateToDetail(university),
          child: Card(
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
          ),
        );
      },
    );
  }
}
