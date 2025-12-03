import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MovieProvider>(context);
    final genreItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(value: null, child: Text('Tous les genres')),
      ...prov.availableGenres.map((g) => DropdownMenuItem(value: g, child: Text(g))),
    ];
    final ratingOptions = <double?>[null, 5, 6, 7, 8, 9];
    final yearOptions = <int?>[null, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025];

    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: (prov.genreFilter.isNotEmpty && prov.availableGenres.contains(prov.genreFilter)) 
                    ? prov.genreFilter 
                    : null,
                hint: const Text('Genre'),
                dropdownColor: Colors.grey.shade900,
                items: genreItems,
                onChanged: (value) {
                  if (value == null) {
                    prov.clearGenre();
                  } else {
                    prov.setGenreFilter(value);
                  }
                },
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<double?>(
                value: prov.minRating,
                hint: const Text('Note minimale'),
                dropdownColor: Colors.grey.shade900,
                items: ratingOptions
                    .map((r) => DropdownMenuItem(
                          value: r?.toDouble(),
                          child: Text(r == null ? 'Toutes' : '$r+'),
                        ))
                    .toList(),
                onChanged: (value) => prov.setMinRating(value),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: prov.minYear,
                hint: const Text('Depuis l\'année'),
                dropdownColor: Colors.grey.shade900,
                items: yearOptions
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y == null ? 'Toutes' : '$y'),
                        ))
                    .toList(),
                onChanged: (value) => prov.setMinYear(value),
              ),
            ),
            IconButton(
              tooltip: 'Réinitialiser',
              onPressed: prov.resetFilters,
              icon: const Icon(Icons.refresh, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

