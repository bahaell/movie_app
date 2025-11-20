import 'package:flutter/material.dart';
import '../../services/matching_service.dart';
import 'movie_details.dart';

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
    commonItemsFuture = _loadCommonItemsDetails();
  }

  Future<List<Map<String, dynamic>>> _loadCommonItemsDetails() async {
    // Fetch common item IDs
    final commonIds = await MatchingService.getCommonItems(
      widget.currentUserId,
      widget.otherUserId,
    );

    // Fetch all details in parallel for better performance
    final detailFutures =
        commonIds.map((id) => MatchingService.getItemDetailsFromTMDB(id));
    final results = await Future.wait(detailFutures);

    // Filter out any empty results and add item metadata
    final validResults = results.where((res) => res.isNotEmpty).toList();
    for (var i = 0; i < validResults.length; i++) {
      final itemId = commonIds.elementAt(i);
      validResults[i]['itemId'] = itemId;
      validResults[i]['itemKind'] = itemId.split('_').first;
    }

    return validResults;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In Common with ${widget.otherUserName}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${widget.similarity.toStringAsFixed(1)}% Match',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final commonItems = snapshot.data ?? [];

          if (commonItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.not_interested,
                      color: Colors.grey.shade600, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'No common favorites found.',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: commonItems.length,
            itemBuilder: (context, index) {
              final item = commonItems[index];
              return _buildCommonItemCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommonItemCard(Map<String, dynamic> item) {
    final title = item['title'] ?? item['name'] ?? 'Untitled';
    final overview = item['overview'] ?? 'No overview available.';
    final posterPath = item['poster_path'];
    final imageUrl = posterPath != null ? '$baseImg$posterPath' : null;
    final itemKind = item['itemKind'] as String? ?? 'movie';
    final id = int.tryParse(item['itemId']?.split('_')[1] ?? '');

    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade800),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailsPage(movieId: id)),
            );
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 150,
              child: Hero(
                tag: 'poster_${item['itemId']}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade800,
                            child:
                                Icon(Icons.movie, color: Colors.grey.shade600),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade800,
                          child: Icon(Icons.movie, color: Colors.grey.shade600),
                        ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      overview,
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade600, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
