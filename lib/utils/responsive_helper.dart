import 'package:flutter/material.dart';

class ResponsiveHelper {
  static final ResponsiveHelper _instance = ResponsiveHelper._internal();
  factory ResponsiveHelper() => _instance;
  ResponsiveHelper._internal();

  // Screen size breakpoints
  static const double _smallScreenBreakpoint = 600;
  static const double _mediumScreenBreakpoint = 800;
  static const double _largeScreenBreakpoint = 1200;

  // Base screen size for scaling (reference design)
  static const double _baseWidth = 375;  // iPhone X width as reference
  static const double _baseHeight = 812; // iPhone X height as reference

  late ScreenSize _currentScreenSize;
  late double _scaleFactor;
  late double _textScaleFactor;

  void initialize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    
    // Determine screen size category
    if (width < _smallScreenBreakpoint) {
      _currentScreenSize = ScreenSize.small;
    } else if (width < _mediumScreenBreakpoint) {
      _currentScreenSize = ScreenSize.medium;
    } else if (width < _largeScreenBreakpoint) {
      _currentScreenSize = ScreenSize.large;
    } else {
      _currentScreenSize = ScreenSize.extraLarge;
    }

    // Calculate scale factors based on screen width
    _scaleFactor = width / _baseWidth;
    _textScaleFactor = MediaQuery.textScalerOf(context).scale(1).clamp(0.8, 1.5);
  }

  ScreenSize get screenSize => _currentScreenSize;
  double get scaleFactor => _scaleFactor;
  double get textScaleFactor => _textScaleFactor;

  // Responsive sizing methods
  double scaledSize(double baseSize) {
    return (baseSize * _scaleFactor).clamp(baseSize * 0.7, baseSize * 1.5);
  }

  double scaledFontSize(double baseFontSize) {
    final scaled = (baseFontSize * _scaleFactor * _textScaleFactor);
    return scaled.clamp(baseFontSize * 0.8, baseFontSize * 1.3);
  }

  EdgeInsets scaledEdgeInsets({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    if (all != 0) {
      return EdgeInsets.all(scaledSize(all));
    }
    if (horizontal != 0 || vertical != 0) {
      return EdgeInsets.symmetric(
        horizontal: scaledSize(horizontal),
        vertical: scaledSize(vertical),
      );
    }
    return EdgeInsets.only(
      left: scaledSize(left),
      top: scaledSize(top),
      right: scaledSize(right),
      bottom: scaledSize(bottom),
    );
  }

  SizedBox scaledSizedBox({double width = 0, double height = 0}) {
    return SizedBox(
      width: width > 0 ? scaledSize(width) : null,
      height: height > 0 ? scaledSize(height) : null,
    );
  }

  // Responsive values for common UI elements
  double get titleFontSize {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledFontSize(32);
      case ScreenSize.medium:
        return scaledFontSize(40);
      case ScreenSize.large:
        return scaledFontSize(48);
      case ScreenSize.extraLarge:
        return scaledFontSize(56);
    }
  }

  double get buttonFontSize {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledFontSize(16);
      case ScreenSize.medium:
        return scaledFontSize(18);
      case ScreenSize.large:
        return scaledFontSize(20);
      case ScreenSize.extraLarge:
        return scaledFontSize(22);
    }
  }

  double get uiFontSize {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledFontSize(14);
      case ScreenSize.medium:
        return scaledFontSize(16);
      case ScreenSize.large:
        return scaledFontSize(18);
      case ScreenSize.extraLarge:
        return scaledFontSize(20);
    }
  }

  double get smallFontSize {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledFontSize(10);
      case ScreenSize.medium:
        return scaledFontSize(12);
      case ScreenSize.large:
        return scaledFontSize(14);
      case ScreenSize.extraLarge:
        return scaledFontSize(16);
    }
  }

  EdgeInsets get screenPadding {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledEdgeInsets(all: 12);
      case ScreenSize.medium:
        return scaledEdgeInsets(all: 16);
      case ScreenSize.large:
        return scaledEdgeInsets(all: 20);
      case ScreenSize.extraLarge:
        return scaledEdgeInsets(all: 24);
    }
  }

  EdgeInsets get buttonPadding {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledEdgeInsets(horizontal: 24, vertical: 12);
      case ScreenSize.medium:
        return scaledEdgeInsets(horizontal: 32, vertical: 16);
      case ScreenSize.large:
        return scaledEdgeInsets(horizontal: 40, vertical: 20);
      case ScreenSize.extraLarge:
        return scaledEdgeInsets(horizontal: 48, vertical: 24);
    }
  }

  double get buttonBorderRadius {
    return scaledSize(25);
  }

  double get iconSize {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledSize(16);
      case ScreenSize.medium:
        return scaledSize(20);
      case ScreenSize.large:
        return scaledSize(24);
      case ScreenSize.extraLarge:
        return scaledSize(28);
    }
  }

  double get gameUIBottomOffset {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledSize(15);
      case ScreenSize.medium:
        return scaledSize(20);
      case ScreenSize.large:
        return scaledSize(25);
      case ScreenSize.extraLarge:
        return scaledSize(30);
    }
  }

  double get gameUITopOffset {
    switch (_currentScreenSize) {
      case ScreenSize.small:
        return scaledSize(30);
      case ScreenSize.medium:
        return scaledSize(40);
      case ScreenSize.large:
        return scaledSize(50);
      case ScreenSize.extraLarge:
        return scaledSize(60);
    }
  }
}

enum ScreenSize {
  small,
  medium,
  large,
  extraLarge,
}

// Extension methods for easier usage
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper();
}
