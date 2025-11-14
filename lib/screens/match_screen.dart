import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/matching_util.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({Key? key}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Movie Matches')),
      body: FutureBuilder<AppUser?>(
        future: _firestoreService.getUser(userId),
        builder: (context, currentUserSnapshot) {
          if (!currentUserSnapshot.hasData || currentUserSnapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = currentUserSnapshot.data!;

          return StreamBuilder<List<AppUser>>(
            stream: _firestoreService.streamAllUsers(),
            builder: (context, allUsersSnapshot) {
              if (!allUsersSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final matches = findMatches(
                userId,
                currentUser.favorites,
                allUsersSnapshot.data ?? [],
              );

              if (matches.isEmpty) {
                return const Center(
                  child: Text('No matches found. Keep adding movies to your favorites!'),
                );
              }

              return ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: match.user.photoUrl.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(match.user.photoUrl),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text('${match.user.firstName} ${match.user.lastName}'),
                      subtitle: Text(
                        'Similarity: ${(match.similarity * 100).toStringAsFixed(1)}% • ${match.commonMovies.length} common movies',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // TODO: Navigate to match details
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
