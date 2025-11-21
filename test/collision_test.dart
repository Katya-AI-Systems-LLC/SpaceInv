import 'package:flutter_test/flutter_test.dart';
import 'package:space_invaders/collision_detection.dart';

void main() {
  group('Collision Detection Tests', () {
    test('checkRectCollision detects collision correctly', () {
      // Overlapping rectangles
      expect(
        checkRectCollision(10, 10, 20, 20, 15, 15, 20, 20),
        true,
      );
      
      // Non-overlapping rectangles
      expect(
        checkRectCollision(10, 10, 20, 20, 100, 100, 20, 20),
        false,
      );
      
      // Touching rectangles
      expect(
        checkRectCollision(10, 10, 20, 20, 30, 10, 20, 20),
        false, // Not overlapping, just touching
      );
    });

    test('checkRectCollision handles edge cases', () {
      // Same position
      expect(
        checkRectCollision(10, 10, 20, 20, 10, 10, 20, 20),
        true,
      );
      
      // One rectangle inside another
      expect(
        checkRectCollision(10, 10, 40, 40, 20, 20, 10, 10),
        true,
      );
    });
  });
}

