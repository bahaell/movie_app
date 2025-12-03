import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieProvider>(context);
    return Wrap(
      spacing: 10,
      children: [
        // Dynamically create chips from available genres
        ...provider.availableGenres.map((g) => FilterChip(
              label: Text(g),
              selected: provider.genreFilter == g,
              onSelected: (sel) => provider.setGenreFilter(sel ? g : ''),
            )),
        // Example rating chip
        FilterChip(
          label: const Text('Rating > 7'),
          selected: provider.minRating != null && provider.minRating! >= 7,
          onSelected: (sel) => provider.setMinRating(sel ? 7 : null),
        ),
      ],
    );
  }
}