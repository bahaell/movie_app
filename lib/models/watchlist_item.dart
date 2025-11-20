class WatchlistItem {
  final int id;
  final String type; // "movie" or "tv"

  WatchlistItem({
    required this.id,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
      };

  factory WatchlistItem.fromMap(Map<String, dynamic> map) {
    return WatchlistItem(
      id: map['id'],
      type: map['type'],
    );
  }
}
