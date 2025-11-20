// Flutter Home User UI (Connected to TMDB API)
// Added: API integration, real data, real images.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String tmdbApiKey = '00498c90aa03a7dbf2659cca75f6a735';
const String baseImg = 'https://image.tmdb.org/t/p/w500';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List nowPlaying = [];
  List popularMovies = [];
  List topRatedMovies = [];
  List onAirTv = [];
  List popularTv = [];
  List topRatedTv = [];

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    nowPlaying = await fetchData('movie/now_playing');
    popularMovies = await fetchData('movie/popular');
    topRatedMovies = await fetchData('movie/top_rated');
    onAirTv = await fetchData('tv/on_the_air');
    popularTv = await fetchData('tv/popular');
    topRatedTv = await fetchData('tv/top_rated');
    setState(() {});
  }

  Future<List> fetchData(String endpoint) async {
    final url = Uri.parse('https://api.themoviedb.org/3/$endpoint?api_key=$tmdbApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['results'] as List? ?? [];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MovieApp',
          style: TextStyle(color: Color(0xFF53FC18), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            icon: const Icon(Icons.favorite, color: Color(0xFF53FC18)),
          ),
          IconButton(
            tooltip: 'Matching',
            onPressed: () => Navigator.pushNamed(context, '/matching'),
            icon: const Icon(Icons.people, color: Color(0xFF53FC18)),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: Color(0xFF53FC18)),
          ),
        ],
      ),
      body: nowPlaying.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF53FC18)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('Now Playing'),
                  movieHorizontalList(nowPlaying),

                  buildSectionTitle('Popular Movies'),
                  movieHorizontalList(popularMovies),

                  buildSectionTitle('Top Rated Movies'),
                  movieHorizontalList(topRatedMovies),

                  buildSectionTitle('On Air TV Shows'),
                  movieHorizontalList(onAirTv),

                  buildSectionTitle('Popular TV Shows'),
                  movieHorizontalList(popularTv),

                  buildSectionTitle('Top Rated TV Shows'),
                  movieHorizontalList(topRatedTv),

                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF53FC18),
        child: const Icon(Icons.search, color: Colors.black),
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF53FC18),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget movieHorizontalList(List data) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return GestureDetector(
            onTap: () {
              final id = item['id'];
              final mediaType = item.containsKey('title') ? 'movie' : 'tv';
              if (mediaType == 'movie') {
                Navigator.pushNamed(context, '/movie', arguments: id);
              } else {
                Navigator.pushNamed(context, '/tv', arguments: id);
              }
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(
                          item['poster_path'] != null
                              ? '$baseImg${item['poster_path']}'
                              : 'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] ?? item['name'] ?? 'No title',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

