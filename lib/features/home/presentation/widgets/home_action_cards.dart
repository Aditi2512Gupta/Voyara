import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../trip_planner/providers/saved_trip_provider.dart';

/// Side-by-side equally sized action cards for "Plan a Trip with AI"
/// and "My Trips" on Voyara's Home page.
class HomeActionCards extends ConsumerWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripsAsync = ref.watch(savedTripsProvider);

    final tripCount = tripsAsync.maybeWhen(
      data: (trips) => trips.length,
      orElse: () => null,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left Card: Plan a Trip with AI
          Expanded(child: _buildPlanWithAiCard(context, isDark: isDark)),

          const SizedBox(width: 14),

          // 2. Right Card: My Trips
          Expanded(
            child: _buildMyTripsCard(
              context,
              isDark: isDark,
              tripCount: tripCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanWithAiCard(BuildContext context, {required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0F3B38), Color(0xFF082220)]
              : const [Color(0xFF13504B), Color(0xFF0A3330)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.30),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0A3330,
            ).withValues(alpha: isDark ? 0.45 : 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle mountain slope decoration in background
            Positioned(
              right: -10,
              bottom: -15,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.terrain_rounded,
                  size: 110,
                  color: Colors.white,
                ),
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/trip-planner'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Compass medallion & Circular Arrow button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Compass rose medallion
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5953), Color(0xFF0A2E2B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.45,
                                ),
                                width: 1,
                              ),
                            ),
                            child: CustomPaint(
                              painter: _CompassPainter(
                                mintColor: AppColors.secondary,
                                coralColor: AppColors.tertiary,
                              ),
                            ),
                          ),

                          // Circular arrow button
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Color(0xFF0A3330),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title & Subtitle Lockup
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Plan a Trip\nwith AI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Get personalized itineraries, routes and travel tips",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTripsCard(
    BuildContext context, {
    required bool isDark,
    required int? tripCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF152828) : const Color(0xFFEFF9F8),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.28)
              : const Color(0xFFCDEFEA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Flight trajectory vector with airplane icon in background
            Positioned(
              right: 8,
              bottom: 8,
              child: CustomPaint(
                size: const Size(64, 48),
                painter: _DottedFlightPathPainter(
                  color: isDark
                      ? AppColors.secondary.withValues(alpha: 0.35)
                      : const Color(0xFF38B29C).withValues(alpha: 0.40),
                ),
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/saved-trips?title=My Trips'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Luggage icon & Circular Arrow button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF1C3D3B)
                                  : const Color(0xFFD6F3EE),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.35,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.luggage_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.secondary
                                  : const Color(0xFF0E504A),
                            ),
                          ),

                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF224240)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.secondary
                                  : const Color(0xFF0A3330),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title, Saved Plans Tag, Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Trips",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : const Color(0xFF0F3533),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Micro-pill Tag: • SAVED PLANS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.secondary.withValues(alpha: 0.15)
                                  : const Color(0xFFDBF4F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.tertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tripCount != null && tripCount > 0
                                      ? "$tripCount SAVED"
                                      : "SAVED PLANS",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: isDark
                                        ? AppColors.secondary
                                        : const Color(0xFF0E5C55),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "View and manage your saved trips",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : const Color(0xFF55706E),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for the compass rose and orange flight arc on the AI card
class _CompassPainter extends CustomPainter {
  const _CompassPainter({required this.mintColor, required this.coralColor});

  final Color mintColor;
  final Color coralColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 3;

    // Outer dial ring
    final dialPaint = Paint()
      ..color = mintColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawCircle(Offset(cx, cy), radius, dialPaint);

    // North needle
    final northPath = Path()
      ..moveTo(cx, cy - radius * 0.7)
      ..lineTo(cx - 2, cy)
      ..lineTo(cx + 2, cy)
      ..close();
    canvas.drawPath(
      northPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Orange trajectory arc
    final arcPaint = Paint()
      ..color = coralColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final arcPath = Path();
    arcPath.moveTo(cx - radius * 0.6, cy + radius * 0.3);
    arcPath.quadraticBezierTo(
      cx,
      cy - radius * 0.4,
      cx + radius * 0.6,
      cy - radius * 0.2,
    );
    canvas.drawPath(arcPath, arcPaint);

    // Center pivot
    canvas.drawCircle(Offset(cx, cy), 1.8, Paint()..color = coralColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the dotted flight path and airplane silhouette on My Trips card
class _DottedFlightPathPainter extends CustomPainter {
  const _DottedFlightPathPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // Draw dotted arc
    final p0 = Offset(4, size.height - 4);
    final p1 = Offset(size.width * 0.4, size.height * 0.55);
    final p2 = Offset(size.width - 14, 14);

    const int steps = 14;
    for (int i = 0; i < steps; i++) {
      final t = i / steps;
      final x =
          math.pow(1 - t, 2) * p0.dx +
          2 * (1 - t) * t * p1.dx +
          math.pow(t, 2) * p2.dx;
      final y =
          math.pow(1 - t, 2) * p0.dy +
          2 * (1 - t) * t * p1.dy +
          math.pow(t, 2) * p2.dy;

      if (i % 2 == 0) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }

    // Mini airplane icon at trajectory tip
    final planePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width - 12, 10);
    canvas.rotate(-math.pi / 4);

    final planePath = Path()
      ..moveTo(0, -6)
      ..lineTo(2, -2)
      ..lineTo(6, 1)
      ..lineTo(2, 1)
      ..lineTo(1, 4)
      ..lineTo(3, 6)
      ..lineTo(-3, 6)
      ..lineTo(-1, 4)
      ..lineTo(-2, 1)
      ..lineTo(-6, 1)
      ..lineTo(-2, -2)
      ..close();

    canvas.drawPath(planePath, planePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
