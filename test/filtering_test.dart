import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/models/movie.dart';

void main() {
  group('Filtering Logic Tests', () {
    // Helper to simulate the logic used in providers
    bool matches(Movie m, {String genre = '', int? minYear, double? minRating}) {
      String normalize(String s) => s.toLowerCase().trim();

      // Genre
      if (genre.isNotEmpty) {
        final target = normalize(genre);
        final gs = (m.genres ?? []).map((g) => normalize(g)).toList();
        bool found = false;
        for (final g in gs) {
          if (g == target || g.contains(target)) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      }

      // Rating
      if (minRating != null) {
        if ((m.vote ?? 0) < minRating) return false;
      }

      // Year
      if (minYear != null) {
        final rd = m.releaseDate;
        if (rd == null || rd.isEmpty) return false;

        int? y;
        if (rd.length >= 4) {
          y = int.tryParse(rd.substring(0, 4));
        }
        if (y == null) {
          try {
            final d = DateTime.tryParse(rd);
            if (d != null) y = d.year;
          } catch (_) {}
        }
        if (y == null || y < minYear) return false;
      }

      return true;
    }

    test('Genre Matching - Exact Match', () {
      final m = Movie(id: '1', title: 'Test', genres: ['Action', 'Comedy']);
      expect(matches(m, genre: 'Action'), isTrue);
      expect(matches(m, genre: 'Comedy'), isTrue);
      expect(matches(m, genre: 'Horror'), isFalse);
    });

    test('Genre Matching - Case Insensitive', () {
      final m = Movie(id: '1', title: 'Test', genres: ['Action']);
      expect(matches(m, genre: 'action'), isTrue);
      expect(matches(m, genre: 'ACTION'), isTrue);
    });

    test('Genre Matching - Partial/Contains', () {
      final m = Movie(id: '1', title: 'Test', genres: ['Sci-Fi & Fantasy']);
      expect(matches(m, genre: 'Sci-Fi'), isTrue);
      expect(matches(m, genre: 'Fantasy'), isTrue);
    });

    test('Year Filtering - Standard Format', () {
      final m = Movie(id: '1', title: 'Test', releaseDate: '2022-05-01');
      expect(matches(m, minYear: 2020), isTrue);
      expect(matches(m, minYear: 2022), isTrue);
      expect(matches(m, minYear: 2023), isFalse);
    });

    test('Year Filtering - Non-Standard Format', () {
      final m = Movie(id: '1', title: 'Test', releaseDate: '2022/05/01');
      expect(matches(m, minYear: 2022), isTrue);
    });

    test('Rating Filtering', () {
      final m = Movie(id: '1', title: 'Test', vote: 7.5);
      expect(matches(m, minRating: 7.0), isTrue);
      expect(matches(m, minRating: 8.0), isFalse);
    });

    test('Combined Filtering', () {
      final m = Movie(id: '1', title: 'Test', genres: ['Action'], releaseDate: '2022-01-01', vote: 8.0);
      expect(matches(m, genre: 'Action', minYear: 2020, minRating: 7.0), isTrue);
      expect(matches(m, genre: 'Comedy', minYear: 2020, minRating: 7.0), isFalse);
      expect(matches(m, genre: 'Action', minYear: 2023, minRating: 7.0), isFalse);
    });
  });
}
