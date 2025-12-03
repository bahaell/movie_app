import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Matching Logic Tests', () {
    // Replicating the logic from MatchingPage
    double calculateRatio(List<String> currentFavs, List<String> otherFavs) {
      if (otherFavs.isEmpty) return 0.0;
      final intersection = otherFavs.where((id) => currentFavs.contains(id)).toList();
      return intersection.isEmpty ? 0.0 : intersection.length / otherFavs.length;
    }

    test('Identical Lists - Should be 100%', () {
      final me = ['A', 'B', 'C'];
      final other = ['A', 'B', 'C'];
      expect(calculateRatio(me, other), 1.0);
    });

    test('Subset (Other is subset of Me) - Should be 100%', () {
      final me = ['A', 'B', 'C', 'D'];
      final other = ['A', 'B'];
      // Intersection is [A, B] (2). Other length is 2. Ratio = 2/2 = 1.0.
      expect(calculateRatio(me, other), 1.0);
    });

    test('Superset (Other has more) - Should be low', () {
      final me = ['A', 'B'];
      final other = ['A', 'B', 'C', 'D'];
      // Intersection is [A, B] (2). Other length is 4. Ratio = 2/4 = 0.5.
      expect(calculateRatio(me, other), 0.5);
    });

    test('Partial Overlap', () {
      final me = ['A', 'B', 'C'];
      final other = ['B', 'C', 'D', 'E'];
      // Intersection is [B, C] (2). Other length is 4. Ratio = 2/4 = 0.5.
      expect(calculateRatio(me, other), 0.5);
    });

    test('No Overlap', () {
      final me = ['A', 'B'];
      final other = ['C', 'D'];
      expect(calculateRatio(me, other), 0.0);
    });
    
    test('User Scenario: 75% Requirement', () {
       // Scenario where it SHOULD match (>= 0.75)
       final me = ['A', 'B', 'C', 'D'];
       final other = ['A', 'B', 'C', 'E']; 
       // Intersection: A, B, C (3). Other: 4. Ratio: 3/4 = 0.75.
       expect(calculateRatio(me, other), 0.75);
    });
  });
}
