import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/watchlist_service.dart';

/// Generic toggle button for adding/removing an item (movie or tv) from the
/// user's watchlist ("favorites" list in Firestore).
///
/// Stores tags formatted as '<kind>_<id>' e.g. 'movie_550' or 'tv_1399'.
class WatchlistToggle extends StatelessWidget {
  final int id;
  final String kind; // 'movie' or 'tv'
  final Color activeColor;
  final Color inactiveColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onChanged; // fired after successful toggle

  const WatchlistToggle({
    super.key,
    required this.id,
    required this.kind,
    this.activeColor = const Color(0xFF53FC18),
    this.inactiveColor = Colors.white70,
    this.iconSize = 28,
    this.padding = const EdgeInsets.all(4),
    this.onChanged,
  });

  String get _tag => '${kind}_$id';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return IconButton(
        onPressed: () {},
        icon: Icon(Icons.favorite_border, color: inactiveColor, size: iconSize),
        tooltip: 'Login required',
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snap) {
        final favorites = <String>[];
        if (snap.hasData && snap.data?.data() != null) {
          final data = snap.data!.data() as Map<String, dynamic>;
          favorites.addAll(List<String>.from(data['favorites'] ?? []));
        }
        final isFav = favorites.contains(_tag);
        return Padding(
          padding: padding,
          child: IconButton(
            onPressed: () async {
              try {
                if (!isFav) {
                  await WatchlistService.addToWatchlist(id, kind);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${kind.toUpperCase()} added to watchlist')),);
                } else {
                  await WatchlistService.removeFromWatchlist(id, kind);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${kind.toUpperCase()} removed from watchlist')),);
                }
                onChanged?.call();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? activeColor : inactiveColor, size: iconSize),
            tooltip: isFav ? 'Remove from watchlist' : 'Add to watchlist',
          ),
        );
      },
    );
  }
}
