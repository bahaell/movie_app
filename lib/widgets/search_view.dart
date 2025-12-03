import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../core/constants.dart';

typedef SearchContentBuilder = Widget Function(BuildContext context, List<Movie> results, bool loading, TextEditingController controller);

class SearchView extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onSearchPressed;
  final bool loading;
  final List<Movie> results;
  final SearchContentBuilder contentBuilder;
  final String hintText;
  final bool fieldInAppBar;

  const SearchView({
    super.key,
    required this.controller,
    required this.contentBuilder,
    this.onChanged,
    this.onSearchPressed,
    this.loading = false,
    this.results = const [],
    this.hintText = 'Search movie...',
    this.fieldInAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SURFACE_DARK,
      appBar: AppBar(
        backgroundColor: SURFACE_DARK,
        title: fieldInAppBar
            ? TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: (_) => onSearchPressed?.call(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: PRIMARY_GREEN),
                    onPressed: onSearchPressed,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              )
            : Text(
                'Search',
                style: const TextStyle(color: PRIMARY_GREEN),
              ),
      ),
      body: Column(
        children: [
          if (!fieldInAppBar)
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSearchPressed?.call(),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: PRIMARY_GREEN),
                    onPressed: onSearchPressed,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: onChanged,
              ),
            ),
          Expanded(child: contentBuilder(context, results, loading, controller)),
        ],
      ),
    );
  }
}
