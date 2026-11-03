import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../shared/widgets/voyara_logo.dart';
import '../../startup_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.controller = const StartupController()});

  final StartupController controller;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  /// Controller for scene and logo entrance (fade and soft scale)
  late final AnimationController _entryController;
  late final Animation<double> _bgFadeAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoSlideAnimation;

  /// Controller for the airplane takeoff and flight into the distance
  late final AnimationController _flightController;

  Timer? _loginTimer;

  @override
  void initState() {
    super.initState();

    // Dark status bar icons on cream sky background for optimal contrast
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // 1. Entry animations
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bgFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );

    _logoSlideAnimation = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Flight animation: airplane departs from letter "O", climbs along contrail, and flies away
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Start entry, then trigger airplane takeoff smoothly
    _entryController.forward().then((_) {
      if (mounted) {
        _flightController.forward();
      }
    });

    _loginTimer = Timer(const Duration(milliseconds: 2800), _checkLogin);
  }

  @override
  void dispose() {
    _loginTimer?.cancel();
    _entryController.dispose();
    _flightController.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    try {
      final loggedIn = await widget.controller.isLoggedIn();

      if (!mounted) return;

      if (loggedIn) {
        NotificationService.instance.scheduleDailyNotification();
        if (mounted) {
          try {
            context.go('/home');
          } catch (_) {}
        }
      } else {
        if (mounted) {
          try {
            context.go('/login');
          } catch (_) {}
        }
      }
    } catch (_) {
      if (!mounted) return;
      try {
        context.go('/login');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF4), // Seamless cream matching sky
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          // Responsive sizing for logo: balanced across compact, standard, and tall phones
          final logoWidth = math.min(size.width * 0.72, 300.0);
          final logoHeight =
              logoWidth * (207.0 / 386.0); // Exact aspect ratio of logo asset

          // Logo sits comfortably in the upper-middle sky with spacious clearance above mountains
          final logoTop = size.height * 0.27;
          final logoLeft = (size.width - logoWidth) / 2;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ===============================================================
              // 1. SCENIC BACKGROUND LANDSCAPE
              // Uses full-proportion voyara_splash_scenery pinned to bottomCenter,
              // showing mountains, lake reflections, and framing palms in their
              // natural, spacious proportions without heavy or zoomed-in cropping.
              // Softly blurred and lightened with a luminous cream veil overlay
              // to lift deep shadows while preserving teal, cream, and peach tones.
              // ===============================================================
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _bgFadeAnimation,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(
                              0xFFFDFBF4,
                            ), // 100% solid cream at top to blend into sky
                            const Color(0xFFFDFBF4).withValues(
                              alpha: 0.82,
                            ), // Soft fade into upper sky
                            const Color(0xFFFDFBF4).withValues(
                              alpha: 0.38,
                            ), // Softens mountains & warm peach sunrise
                            const Color(0xFFFDFBF4).withValues(
                              alpha: 0.30,
                            ), // Keeps serene lake water reflections luminous
                            const Color(0xFFFDFBF4).withValues(
                              alpha: 0.36,
                            ), // Lifts dark shadows of bottom foliage!
                          ],
                          stops: const [0.0, 0.42, 0.65, 0.82, 1.0],
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/voyara_splash_scenery.png',
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // 2. VOYARA BRAND LOGO BASE
              // Displays the clean "Voyara" wordmark, circular "O" landscape,
              // and the curved flight contrail path (without static plane).
              // ===============================================================
              Positioned(
                left: logoLeft,
                top: logoTop,
                width: logoWidth,
                height: logoHeight,
                child: AnimatedBuilder(
                  animation: _entryController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _logoSlideAnimation.value),
                      child: Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/voyara_logo_without_plane.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: VoyaraLogo.primary(size: 90)),
                  ),
                ),
              ),

              // ===============================================================
              // 3. ANIMATED AIRPLANE & CONTRAIL VAPOR TRAIL
              // Starts near the letter "O", climbs along the existing contrail
              // curve, and soars smoothly away into the upper-right sky,
              // scaling down and fading as it gains altitude into the distance.
              // ===============================================================
              Positioned(
                left: logoLeft,
                top: logoTop,
                width: logoWidth,
                height: logoHeight,
                child: AnimatedBuilder(
                  animation: _flightController,
                  builder: (context, _) {
                    return _buildAnimatedAirplane(logoWidth, logoHeight);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the animated airplane with smooth flight trajectory, scaling,
  /// rotation matching the flight angle, and fading away into distance.
  Widget _buildAnimatedAirplane(double logoW, double logoH) {
    final t = _flightController.value.clamp(0.0, 1.0);
    if (t <= 0.0) return const SizedBox.shrink();

    // 1. Compute flight position along the curved trajectory
    final pos = _computeFlightPosition(t, logoW, logoH);

    // 2. Compute heading angle along tangent vector
    final heading = _computeFlightHeading(t, logoW, logoH);

    // The airplane sprite is naturally angled at -38.7 degrees (-0.675 rad)
    const baseSpriteAngle = -0.675;
    final rotationAngle = heading - baseSpriteAngle;

    // 3. Scale and Opacity profile:
    // - Starts near letter "O" (t=0.0): emerges from scale 0.70 to 1.0, fades in quickly
    // - Along the contrail (t=0.15 to 0.42): full size (1.0) and full opacity (1.0)
    // - Flying away into the distance (t=0.42 to 1.0): shrinks from 1.0 to 0.32, fades to 0.0
    double scale;
    double opacity;

    if (t < 0.15) {
      final u = (t / 0.15).clamp(0.0, 1.0);
      opacity = Curves.easeOut.transform(u);
      scale = 0.70 + (0.30 * u);
    } else if (t < 0.42) {
      opacity = 1.0;
      scale = 1.0;
    } else {
      // Clamping strictly ensures floating point rounding (e.g. 1.0000000000000002) never exceeds 1.0
      final u = ((t - 0.42) / 0.58).clamp(0.0, 1.0);
      final easeU = Curves.easeIn.transform(u);
      scale = 1.0 - (0.68 * easeU); // Scales down to 0.32 in the far distance
      opacity = (1.0 - easeU).clamp(0.0, 1.0); // Fades into the sky
    }

    // When the airplane has finished flying away and faded, avoid rendering
    if (opacity <= 0.0) return const SizedBox.shrink();

    final planeBaseWidth =
        logoW * 0.145; // Matches exact size in the logo artwork

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Faint, elegant travel vapor trail behind the airplane
        if (t > 0.25)
          CustomPaint(
            size: Size(logoW, logoH),
            painter: _ContrailVaporPainter(
              flightProgress: t,
              logoW: logoW,
              logoH: logoH,
            ),
          ),

        // Animated Airplane Sprite
        Positioned(
          left: pos.dx - (planeBaseWidth * 0.5),
          top: pos.dy - (planeBaseWidth * 0.5),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotationAngle,
                child: Image.asset(
                  'assets/images/voyara_airplane.png',
                  width: planeBaseWidth,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.flight_rounded,
                    size: planeBaseWidth,
                    color: const Color(0xFF0E3D42),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Parametric flight path:
  /// - Phase 1 (0.0 <= t <= 0.40): Follows the existing contrail curve from the 'O'
  /// - Phase 2 (0.40 < t <= 1.00): Ascends smoothly away into the upper-right distance
  static Offset _computeFlightPosition(double t, double w, double h) {
    final clampedT = t.clamp(0.0, 1.0);
    if (clampedT <= 0.40) {
      // Phase 1: quadratic curve along the logo's printed contrail
      final u = (clampedT / 0.40).clamp(0.0, 1.0);
      final p0 = Offset(w * 0.430, h * 0.385); // Near rim of letter 'O'
      final p1 = Offset(w * 0.525, h * 0.280); // Contrail arc midpoint
      final p2 = Offset(w * 0.622, h * 0.193); // End of printed contrail

      final x =
          (1 - u) * (1 - u) * p0.dx + 2 * (1 - u) * u * p1.dx + u * u * p2.dx;
      final y =
          (1 - u) * (1 - u) * p0.dy + 2 * (1 - u) * u * p1.dy + u * u * p2.dy;
      return Offset(x, y);
    } else {
      // Phase 2: soaring away into the distance
      final u = ((clampedT - 0.40) / 0.60).clamp(0.0, 1.0);
      final p2 = Offset(w * 0.622, h * 0.193);
      final control = Offset(w * 1.08, h * -0.22);
      final pFar = Offset(w * 1.82, h * -0.78);

      final x =
          (1 - u) * (1 - u) * p2.dx +
          2 * (1 - u) * u * control.dx +
          u * u * pFar.dx;
      final y =
          (1 - u) * (1 - u) * p2.dy +
          2 * (1 - u) * u * control.dy +
          u * u * pFar.dy;
      return Offset(x, y);
    }
  }

  /// Computes tangent angle at progress [t]
  static double _computeFlightHeading(double t, double w, double h) {
    final clampedT = t.clamp(0.0, 1.0);
    const delta = 0.01;
    final t1 = (clampedT - delta).clamp(0.0, 1.0);
    final t2 = (clampedT + delta).clamp(0.0, 1.0);
    final pos1 = _computeFlightPosition(t1, w, h);
    final pos2 = _computeFlightPosition(t2, w, h);
    return math.atan2(pos2.dy - pos1.dy, pos2.dx - pos1.dx);
  }
}

/// Paints subtle, delicate fading contrail vapor particles behind the plane
class _ContrailVaporPainter extends CustomPainter {
  final double flightProgress;
  final double logoW;
  final double logoH;

  _ContrailVaporPainter({
    required this.flightProgress,
    required this.logoW,
    required this.logoH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (flightProgress < 0.25) return;

    // Draw small soft vapor puffs trailing behind the plane
    final paint = Paint()
      ..color = const Color(0xFF0E3D42).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    const count = 5;
    for (int i = 1; i <= count; i++) {
      final trailT = flightProgress - (i * 0.04);
      if (trailT < 0.10) continue;

      final pos = _SplashPageState._computeFlightPosition(
        trailT.clamp(0.0, 1.0),
        logoW,
        logoH,
      );
      final alpha = (1.0 - (i / (count + 1))) * 0.22;
      paint.color = const Color(0xFF0E3D42).withValues(alpha: alpha);

      canvas.drawCircle(pos, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ContrailVaporPainter oldDelegate) {
    return oldDelegate.flightProgress != flightProgress;
  }
}
