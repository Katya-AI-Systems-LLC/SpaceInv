import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/responsive_helper.dart';

void main() {
  group('ResponsiveHelper Tests', () {
    testWidgets('should initialize without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final responsive = ResponsiveHelper();
              responsive.initialize(context);
              
              // Test that values are reasonable
              expect(responsive.scaleFactor, greaterThan(0));
              expect(responsive.titleFontSize, greaterThan(0));
              expect(responsive.buttonFontSize, greaterThan(0));
              expect(responsive.uiFontSize, greaterThan(0));
              expect(responsive.smallFontSize, greaterThan(0));
              
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should scale sizes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final responsive = ResponsiveHelper();
              responsive.initialize(context);
              
              // Test scaled size
              const baseSize = 100.0;
              final scaledSize = responsive.scaledSize(baseSize);
              expect(scaledSize, isA<double>());
              expect(scaledSize, greaterThan(0));
              
              // Test scaled font size
              const baseFontSize = 20.0;
              final scaledFontSize = responsive.scaledFontSize(baseFontSize);
              expect(scaledFontSize, isA<double>());
              expect(scaledFontSize, greaterThan(0));
              
              // Test scaled padding
              final padding = responsive.scaledEdgeInsets(all: 16);
              expect(padding, isA<EdgeInsets>());
              
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should provide consistent responsive values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final responsive = ResponsiveHelper();
              responsive.initialize(context);
              
              // Test that responsive values are consistent
              expect(responsive.titleFontSize, greaterThan(responsive.buttonFontSize));
              expect(responsive.buttonFontSize, greaterThan(responsive.uiFontSize));
              expect(responsive.uiFontSize, greaterThan(responsive.smallFontSize));
              
              // Test that icon sizes are reasonable
              expect(responsive.iconSize, greaterThan(10));
              expect(responsive.iconSize, lessThan(50));
              
              return Container();
            },
          ),
        ),
      );
    });
  });
}
