import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_movie_provider.dart';
import '../../core/constants.dart';
import '../../widgets/admin/movie_card_admin.dart';

class AdminLibraryPage extends StatelessWidget {
  const AdminLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AdminMovieProvider>(context);
    final movies = prov.filteredFirebaseMovies();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              DropdownButton<String>(
                value: (prov.currentGenre.isNotEmpty && prov.availableGenres.contains(prov.currentGenre))
                    ? prov.currentGenre
                    : '',
                hint: const Text('Genre', style: TextStyle(color: Colors.white70)),
                dropdownColor: Colors.grey.shade900,
                items: [
                  const DropdownMenuItem(value: '', child: Text('Any')),
                  ...prov.availableGenres.map((g) => DropdownMenuItem(value: g, child: Text(g)))
                ],
                onChanged: (v) => prov.setGenre(v ?? ''),
              ),
              const SizedBox(width: 12),
              DropdownButton<double>(
                value: prov.minRating,
                hint: const Text('Rating'),
                dropdownColor: Colors.grey.shade900,
                items: [null,5,6,7,8,9].map((r) => DropdownMenuItem(value: r?.toDouble(), child: Text(r==null ? 'Any' : r.toString()))).toList(),
                onChanged: (v) => prov.setMinRating(v),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: prov.minYear,
                hint: const Text('Year'),
                dropdownColor: Colors.grey.shade900,
                items: [null,2018,2019,2020,2021,2022,2023,2024,2025].map((y) => DropdownMenuItem(value: y, child: Text(y==null? 'Any': y.toString()))).toList(),
                onChanged: (v) => prov.setMinYear(v),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: PRIMARY_GREEN),
                onPressed: () async => await prov.loadFirebaseMovies(),
              )
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: .6, crossAxisSpacing: 12, mainAxisSpacing: 12
                ),
                itemCount: movies.length,
                itemBuilder: (_, i) => MovieCardAdmin.firebase(movie: movies[i]),
              ),
            )
          ],
        ),
      ),
    );
  }
}