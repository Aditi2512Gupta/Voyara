import 'package:flutter/material.dart';

/// Screen type categorization for responsive UI design.
enum ScreenType {
  compact, // Very small mobile (< 360px)
  mobile, // Standard mobile (360px - 599px)
  tablet, // Tablet / foldable unfolded (600px - 1023px)
  desktop, // Desktop / large landscape (>= 1024px)
}

/// Comprehensive responsiveness utility for Voyara.
///
/// Provides breakpoints, layout builders, adaptive values, and scaling helpers
/// without relying on external state, ensuring seamless rendering across
/// phones, foldables, tablets, and orientation changes.
class Responsive {
  Responsive._();

  static const double compactBreakpoint = 360;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
  static const double maxContentWidth = 1000;

  /// Returns the current screen type.
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactBreakpoint) return ScreenType.compact;
    if (width < tabletBreakpoint) return ScreenType.mobile;
    if (width < desktopBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  /// True if device width is less than 600px.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// True if device width is less than 360px.
  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < compactBreakpoint;

  /// True if device width is between 600px and 1023px.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// True if device width is 1024px or wider.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Returns an adaptive value based on the screen width.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? compact,
    T? tablet,
    T? desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.compact:
        return compact ?? mobile;
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Returns an optimal grid cross axis count for destination/card grids.
  static int gridCrossAxisCount(
    BuildContext context, {
    int compact = 1,
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactBreakpoint) return compact;
    if (width < tabletBreakpoint) return mobile;
    if (width < desktopBreakpoint) return tablet;
    return desktop;
  }

  /// Standard horizontal screen margin/padding based on screen size.
  static double horizontalPadding(BuildContext context) {
    return value<double>(
      context,
      compact: 12,
      mobile: 18,
      tablet: 28,
      desktop: 36,
    );
  }

  /// Text scale factor clamped between 0.85 and 1.25 to prevent
  /// extreme accessibility scaling from overflowing UI cards.
  static MediaQueryData clampedMediaQuery(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.copyWith(
      textScaler: data.textScaler.clamp(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.20,
      ),
    );
  }
}

/// Convenience extensions on [BuildContext] for responsive layout.
extension ResponsiveContext on BuildContext {
  ScreenType get screenType => Responsive.getScreenType(this);
  bool get isCompact => Responsive.isCompact(this);
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  T responsive<T>({required T mobile, T? compact, T? tablet, T? desktop}) =>
      Responsive.value<T>(
        this,
        mobile: mobile,
        compact: compact,
        tablet: tablet,
        desktop: desktop,
      );

  double get responsiveHorizontalPadding => Responsive.horizontalPadding(this);
}

/// A container that centers and constrains content on wider displays
/// (like tablets and desktops) so the layout does not stretch awkwardly.
class ResponsiveContentWrapper extends StatelessWidget {
  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget current = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (padding != null) {
      current = Padding(padding: padding!, child: current);
    }

    return current;
  }
}
