import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'matching_page.dart';
import 'search_page.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  int index = 0;

  final List<Widget> pages = const [
    HomePageUser(),
    SearchPageUser(),
    FavoritesPage(),
    MatchingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: SURFACE_DARK,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: SURFACE_DARK,
          selectedItemColor: PRIMARY_GREEN,
          unselectedItemColor: Colors.white54,
          currentIndex: index,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Matching',
            ),
          ],
        ),
      ),
    );
  }
}
