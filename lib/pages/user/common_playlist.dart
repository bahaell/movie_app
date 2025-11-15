import 'package:flutter/material.dart';
import '../../services/matching_service.dart';
import 'movie_details.dart';
import 'tv_details.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class CommonPlaylistPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final double similarity;
  final String currentUserId;

  const CommonPlaylistPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.similarity,
    required this.currentUserId,
  });

  @override
  State<CommonPlaylistPage> createState() => _CommonPlaylistPageState();
}

class _CommonPlaylistPageState extends State<CommonPlaylistPage> {
  late Future<List<Map<String, dynamic>>> commonItemsFuture;

  @override
  void initState() {
    super.initState();
    commonItemsFuture = MatchingService.getCommonItemsDetails(
      widget.currentUserId,
      widget.otherUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Color(0xFF53FC18),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.similarity.toStringAsFixed(1)}% Match',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: commonItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF53FC18)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading common items: ${snapshot.error}',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }

          final commonItems = snapshot.data ?? [];

          if (commonItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.not_interested,
                    color: Colors.grey.shade600,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No common favorites',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header with stats
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900!, Colors.grey.shade800!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${commonItems.length} ${commonItems.length == 1 ? 'favorite' : 'favorites'} in common',
                        style: const TextStyle(
                          color: Color(0xFF53FC18),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You and ${widget.otherUserName} both love these movies & shows',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Common items list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = commonItems[index];
                    return _buildCommonItemCard(item);
                  },
                  childCount: commonItems.length,
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: const SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommonItemCard(Map<String, dynamic> item) {
    final title = item['title'] ?? item['name'] ?? 'Untitled';
    final overview = item['overview'] ?? '';
    final posterPath = item['poster_path'];
    final rating = item['vote_average'] ?? 0.0;
    final itemId = item['itemId'] as String?;
    final itemKind = item['itemKind'] as String? ?? 'movie';

    final imageUrl =
        posterPath != null ? '$baseImg$posterPath' : null;

    final id = itemId != null ? int.tryParse(itemId.split('_')[1]) : null;

    return GestureDetector(
      onTap: () {
        if (id != null) {
          if (itemKind == 'movie') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailsPage(movieId: id),
              ),
            );
          } else if (itemKind == 'tv') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TvDetailsPage(tvId: id),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade900,
          border: Border.all(
            color: const Color(0xFF53FC18).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Poster image
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey.shade800,
                      child: Icon(
                        itemKind == 'movie' ? Icons.movie : Icons.tv,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  itemKind == 'movie' ? Icons.movie : Icons.tv,
                  color: Colors.grey.shade600,
                ),
              ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF53FC18),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Type and rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF53FC18).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            itemKind.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF53FC18),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Overview
                    Text(
                      overview.length > 100
                          ? '${overview.substring(0, 100)}...'
                          : overview,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade600,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
