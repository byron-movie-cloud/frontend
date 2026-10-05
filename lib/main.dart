import 'package:flutter/material.dart';

void main() {
  runApp(const MovieCloudApp());
}

class MovieCloudApp extends StatelessWidget {
  const MovieCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF202820);
    const leaf = Color(0xFF32634D);

    return MaterialApp(
      title: 'Movie Cloud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(
          seedColor: leaf,
          brightness: Brightness.light,
          surface: const Color(0xFFF7F8F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F4),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: ink,
              displayColor: ink,
            ),
      ),
      home: const MovieLibraryPage(),
    );
  }
}

class MovieLibraryPage extends StatefulWidget {
  const MovieLibraryPage({super.key});

  @override
  State<MovieLibraryPage> createState() => _MovieLibraryPageState();
}

class _MovieLibraryPageState extends State<MovieLibraryPage> {
  final _searchController = TextEditingController();
  final _movies = <_MovieRecord>[];
  String _query = '';

  List<_MovieRecord> get _visibleMovies {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _movies;
    return _movies
        .where((movie) => movie.title.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _addMovie() async {
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    final movie = await showDialog<_MovieRecord>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a movie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => Navigator.pop(
                context,
                _movieFromFields(titleController.text, yearController.text),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Release year'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _movieFromFields(titleController.text, yearController.text),
            ),
            child: const Text('Add movie'),
          ),
        ],
      ),
    );
    titleController.dispose();
    yearController.dispose();

    if (movie != null && mounted) {
      setState(() => _movies.insert(0, movie));
    }
  }

  _MovieRecord? _movieFromFields(String title, String year) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return null;
    return _MovieRecord(trimmedTitle, int.tryParse(year.trim()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = _visibleMovies;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined, size: 23),
            SizedBox(width: 10),
            Text('Movie Cloud'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Center(
              child: Text(
                'COLLECTION',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: const Color(0xFF687369),
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your collection',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${_movies.length} titles',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF687369)),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addMovie,
                      icon: const Icon(Icons.add),
                      label: const Text('Add movie'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 420,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search your collection',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFDDE2DA)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFDDE2DA)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: movies.isEmpty
                      ? _EmptyCollection(
                          hasQuery: _query.trim().isNotEmpty,
                          onAddMovie: _addMovie,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = (constraints.maxWidth / 250)
                                .floor()
                                .clamp(1, 4)
                                .toInt();
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.76,
                              ),
                              itemCount: movies.length,
                              itemBuilder: (context, index) => _MovieTile(
                                movie: movies[index],
                                index: index,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.hasQuery, required this.onAddMovie});

  final bool hasQuery;
  final VoidCallback onAddMovie;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 190;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_movies_outlined,
                size: compact ? 32 : 42,
                color: const Color(0xFF55745D),
              ),
              SizedBox(height: compact ? 6 : 16),
              Text(
                hasQuery
                    ? 'No titles match that search'
                    : 'A good story starts here',
                style: (compact
                        ? Theme.of(context).textTheme.titleMedium
                        : Theme.of(context).textTheme.titleLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!hasQuery) ...[
                if (!compact) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Add a cool new movie to begin building your collection.',
                    style: TextStyle(color: Color(0xFF687369)),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: onAddMovie,
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first movie'),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: onAddMovie,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add your first movie'),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MovieTile extends StatelessWidget {
  const _MovieTile({required this.movie, required this.index});

  final _MovieRecord movie;
  final int index;

  static const _posterColors = [
    Color(0xFF285B4B),
    Color(0xFFB65E3C),
    Color(0xFF526A85),
    Color(0xFF9A803D),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _posterColors[index % _posterColors.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.local_movies_outlined,
              size: 38,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (movie.year != null)
          Text(
            '${movie.year}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: const Color(0xFF687369)),
          ),
      ],
    );
  }
}

class _MovieRecord {
  const _MovieRecord(this.title, this.year);

  final String title;
  final int? year;
}
