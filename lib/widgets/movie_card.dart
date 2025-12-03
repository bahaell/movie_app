import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/watchlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import 'package:shimmer/shimmer.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onTap;
  const MovieCard({super.key, required this.movie, this.onTap});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isFav = false;
  bool loadingFav = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
      try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final list = await WatchlistService.getWatchlistOnce(uid);
      if (mounted) {
        setState(() => isFav = list.contains(widget.movie.id));
      }
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    if (loadingFav) {
      return;
    }
    setState(() => loadingFav = true);
    if (isFav) {
      await WatchlistService.removeFromWatchlist(widget.movie.id);
    } else {
      await WatchlistService.addToWatchlist(widget.movie.id);
    }
    await _checkFav();
    if (mounted) {
      setState(() => loadingFav = false);
    }
  }

  @override
  Widget build(BuildContext context) {
  final poster = widget.movie.posterUrl.isNotEmpty ? widget.movie.posterUrl : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'movie_${widget.movie.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
            child: poster != null
                          ? CachedNetworkImage(
                              imageUrl: poster,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade800,
                                highlightColor: Colors.grey.shade700,
                                child: Container(color: Colors.grey.shade800),
                              ),
                              errorWidget: (c, u, e) => Container(color: Colors.grey.shade800),
                            )
                          : Container(color: Colors.grey.shade800),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () async {
                        await _toggleFav();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                            color: PRIMARY_GREEN),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(children: [
                Text(widget.movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 6),
                widget.movie.vote != null
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.star, color: PRIMARY_GREEN, size: 16),
                        const SizedBox(width: 6),
                        Text(widget.movie.vote.toString(), style: const TextStyle(color: Colors.white70)),
                      ])
                    : const SizedBox.shrink(),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
