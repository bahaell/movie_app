import 'package:flutter/material.dart';
import '../../services/matching_service.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class CommonPlaylistPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final double similarity;

  const CommonPlaylistPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.similarity,
  });

  @override
  State<CommonPlaylistPage> createState() => _CommonPlaylistPageState();
}

class _CommonPlaylistPageState extends State<CommonPlaylistPage> {
  late Future<Set<String>> commonItemsFuture;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    // TODO: Get current user ID from FirebaseAuth
    // For now, using a placeholder
    currentUserId = 'current_user_id';
    commonItemsFuture =
        MatchingService.getCommonItems(currentUserId, widget.otherUserId);
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
      body: FutureBuilder<Set<String>>(
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
                'Error loading common items',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }

          final commonItems = snapshot.data ?? {};

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

          return Column(
            children: [
              // Header with stats
              Container(
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
                      '${commonItems.length} favorites in common',
                      style: const TextStyle(
                        color: Color(0xFF53FC18),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You and ${widget.otherUserName} share these movies & shows',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Common items grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: commonItems.length,
                  itemBuilder: (context, index) {
                    final itemId = commonItems.elementAt(index);
                    return _buildCommonItemCard(itemId);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommonItemCard(String itemId) {
    // Parse the item ID (format: movie_123 or tv_456)
    final parts = itemId.split('_');
    final kind = parts.isNotEmpty ? parts[0] : '';
    final id = parts.length > 1 ? parts[1] : '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade900,
        border: Border.all(
          color: const Color(0xFF53FC18),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Placeholder or image would go here
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  kind == 'movie' ? Icons.movie : Icons.tv,
                  color: const Color(0xFF53FC18),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  kind.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF53FC18),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ID badge
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#$id',
                style: const TextStyle(
                  color: Color(0xFF53FC18),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
