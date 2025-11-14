import 'package:flutter/material.dart';

class MovieCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onFavorite;
  final bool isFavorited;

  const MovieCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onFavorite,
    this.isFavorited = false,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF53fc18), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF53fc18).withOpacity(0.3),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              widget.imageUrl,
              height: 200,
              width: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 160,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, 
                      color: Color(0xFF53fc18)),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF53fc18),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isFavorited = !_isFavorited);
                      widget.onFavorite();
                    },
                    icon: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFF53fc18),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
