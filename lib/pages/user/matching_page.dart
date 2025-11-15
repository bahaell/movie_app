import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_match.dart';
import '../../services/matching_service.dart';
import 'common_playlist.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  late Future<List<UserMatch>> matchesFuture;
  final TextEditingController _searchController = TextEditingController();
  List<UserMatch> allMatches = [];
  List<UserMatch> filteredMatches = [];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      matchesFuture = MatchingService.calculateMatches(uid);
    } else {
      matchesFuture = Future.value([]);
    }
  }

  void _filterMatches(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMatches = allMatches;
      } else {
        filteredMatches = allMatches
            .where((match) =>
                (match.userDisplayName ?? 'Unknown')
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                match.userId.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Find Your Match',
          style: TextStyle(
            color: Color(0xFF53FC18),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<UserMatch>>(
        future: matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF53FC18)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading matches',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          allMatches = snapshot.data ?? [];
          if (filteredMatches.isEmpty) {
            filteredMatches = allMatches;
          }

          if (allMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: Colors.grey.shade600,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matches found',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add more favorites to find users with similar taste!',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterMatches,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF53FC18)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF53FC18)),
                            onPressed: () {
                              _searchController.clear();
                              _filterMatches('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Matches count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Found ${filteredMatches.length} match${filteredMatches.length == 1 ? '' : 'es'}',
                      style: const TextStyle(
                        color: Color(0xFF53FC18),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Matches list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMatches.length,
                  itemBuilder: (context, index) {
                    return _buildMatchCard(filteredMatches[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(UserMatch match) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommonPlaylistPage(
              currentUserId: currentUserId,
              otherUserId: match.userId,
              otherUserName: match.userDisplayName ?? 'Unknown',
              similarity: match.similarity,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900!, Colors.grey.shade800!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color.lerp(
              Colors.grey.shade700,
              const Color(0xFF53FC18),
              match.similarity / 100,
            )!,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with Hero animation
              Hero(
                tag: 'avatar_${match.userId}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: match.userPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(match.userPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey.shade700,
                  ),
                  child: match.userPhotoUrl == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                          size: 28,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // User info and similarity bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      match.userDisplayName ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Similarity bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: match.similarity / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade700,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getSimilarityColor(match.similarity),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Similarity percentage and common items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${match.similarity.toStringAsFixed(1)}% match',
                          style: const TextStyle(
                            color: Color(0xFF53FC18),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${match.commonItems} in common',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Forward arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Color.lerp(
                  Colors.grey.shade600,
                  const Color(0xFF53FC18),
                  match.similarity / 100,
                ),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 90) return const Color(0xFF00FF00);
    if (similarity >= 80) return const Color(0xFF53FC18);
    if (similarity >= 75) return const Color(0xFFFFAA00);
    return const Color(0xFFFF6B6B);
  }
}
