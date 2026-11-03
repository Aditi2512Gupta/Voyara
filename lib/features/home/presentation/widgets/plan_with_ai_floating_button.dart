import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';

/// A distinctive, premium travel-inspired floating action element for Voyara's AI Trip Planner.
///
/// Features:
/// - A custom-crafted Compass Rose & Flight Trajectory Vector medallion
/// - Layered aerodynamic chassis in dark teal with subtle mint and coral rim lights
/// - Prominent, readable "Plan a Trip" typography with a secondary "AI SMART ROUTE" micro-tag
/// - Polished micro-interactions including springy press compression and compass deflection
class PlanWithAiFloatingButton extends StatefulWidget {
  const PlanWithAiFloatingButton({super.key, this.onPressed});

  /// Optional override for button tap. Defaults to navigating to `/trip-planner`.
  final VoidCallback? onPressed;

  @override
  State<PlanWithAiFloatingButton> createState() =>
      _PlanWithAiFloatingButtonState();
}

class _PlanWithAiFloatingButtonState extends State<PlanWithAiFloatingButton> {
  bool _isPressed = false;

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      context.push('/trip-planner');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const coralAccent = AppColors.tertiary; // Coral / terracotta #F26E42
    const mintAccent = AppColors.secondary; // Mint #2EC4B6

    final chassisGradient = isDark
        ? const [Color(0xFF112E2E), Color(0xFF091C1C)]
        : const [AppColors.primary, Color(0xFF134242)];

    return Semantics(
      button: true,
      label: 'Plan a Trip',
      hint: 'Opens the AI Trip Planner itinerary generator',
      child: Tooltip(
        message: 'Plan a Trip with AI',
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              // Aerodynamic, forward-tapered silhouette
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(27),
                bottomLeft: Radius.circular(27),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: chassisGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isDark
                    ? mintAccent.withValues(alpha: 0.38)
                    : mintAccent.withValues(alpha: 0.30),
                width: 1.2,
              ),
              boxShadow: [
                // Deep midnight-teal ground shadow for refined elevation
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.65 : 0.38,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                  spreadRadius: 0,
                ),
                // Tasteful warm coral ambient rim glow
                BoxShadow(
                  color: coralAccent.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(27),
                bottomLeft: Radius.circular(27),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: InkWell(
                key: const Key('plan_with_ai_fab'),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(27),
                  bottomLeft: Radius.circular(27),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                splashColor: mintAccent.withValues(alpha: 0.22),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: _handleTap,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 13,
                    top: 5,
                    bottom: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Compass Rose & Flight Trajectory Vector Medallion
                      AnimatedRotation(
                        // Playful compass deflection on press
                        turns: _isPressed ? 0.05 : 0.0,
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF164848), Color(0xFF092525)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: mintAccent.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.32),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            size: const Size(42, 42),
                            painter: CompassFlightPathPainter(
                              tealColor: AppColors.primary,
                              mintColor: mintAccent,
                              coralColor: coralAccent,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 2. High-Contrast Typography & Subtitle Lockup
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan a Trip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Coral origin waypoint dot
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: coralAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI SMART ROUTE',
                                style: TextStyle(
                                  color: mintAccent.withValues(alpha: 0.95),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      // 3. Trailing Vector Chevron
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: mintAccent.withValues(alpha: 0.70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering a luxury navigation compass rose and an energetic
/// flight-trajectory vector path.
class CompassFlightPathPainter extends CustomPainter {
  CompassFlightPathPainter({
    required this.tealColor,
    required this.mintColor,
    required this.coralColor,
    required this.isDark,
  });

  final Color tealColor;
  final Color mintColor;
  final Color coralColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 2.5;

    // 1. Concentric Navigation Rings
    final outerDialPaint = Paint()
      ..color = mintColor.withValues(alpha: isDark ? 0.40 : 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(cx, cy), radius, outerDialPaint);

    final innerDialPaint = Paint()
      ..color = mintColor.withValues(alpha: isDark ? 0.20 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(cx, cy), radius * 0.65, innerDialPaint);

    // 2. Cardinal Compass Ticks (N, S, E, W)
    final cardinalPaint = Paint()
      ..color = mintColor.withValues(alpha: isDark ? 0.70 : 0.60)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // North (prominent)
    canvas.drawLine(
      Offset(cx, cy - radius),
      Offset(cx, cy - radius + 3.5),
      cardinalPaint..color = mintColor,
    );
    // South
    canvas.drawLine(
      Offset(cx, cy + radius),
      Offset(cx, cy + radius - 2.5),
      cardinalPaint..color = mintColor.withValues(alpha: 0.5),
    );
    // East
    canvas.drawLine(
      Offset(cx + radius, cy),
      Offset(cx + radius - 2.5, cy),
      cardinalPaint..color = mintColor.withValues(alpha: 0.5),
    );
    // West
    canvas.drawLine(
      Offset(cx - radius, cy),
      Offset(cx - radius + 2.5, cy),
      cardinalPaint..color = mintColor.withValues(alpha: 0.5),
    );

    // 3. Subtle Intercardinal Dots (NE, SE, SW, NW)
    final dotPaint = Paint()
      ..color = mintColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    const dotDistanceRatio = 0.82;
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) + (i * math.pi / 2);
      final dx = cx + (radius * dotDistanceRatio) * math.cos(angle);
      final dy = cy + (radius * dotDistanceRatio) * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 0.9, dotPaint);
    }

    // 4. Dimensional Compass Rose (4-point faceted star)
    // North needle (white & mint two-tone facets)
    final northFacet1 = Path()
      ..moveTo(cx, cy - radius * 0.55)
      ..lineTo(cx - 2.2, cy)
      ..lineTo(cx, cy - 0.8)
      ..close();
    canvas.drawPath(
      northFacet1,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    final northFacet2 = Path()
      ..moveTo(cx, cy - radius * 0.55)
      ..lineTo(cx + 2.2, cy)
      ..lineTo(cx, cy - 0.8)
      ..close();
    canvas.drawPath(
      northFacet2,
      Paint()
        ..color = mintColor
        ..style = PaintingStyle.fill,
    );

    // South needle
    final southFacet = Path()
      ..moveTo(cx, cy + radius * 0.45)
      ..lineTo(cx - 1.8, cy)
      ..lineTo(cx + 1.8, cy)
      ..close();
    canvas.drawPath(
      southFacet,
      Paint()
        ..color = isDark ? const Color(0xFF1B4040) : const Color(0xFF143B3B)
        ..style = PaintingStyle.fill,
    );

    // East & West lateral needle facets
    final eastFacet = Path()
      ..moveTo(cx + radius * 0.45, cy)
      ..lineTo(cx, cy - 1.6)
      ..lineTo(cx, cy + 1.6)
      ..close();
    canvas.drawPath(
      eastFacet,
      Paint()
        ..color = mintColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill,
    );

    final westFacet = Path()
      ..moveTo(cx - radius * 0.45, cy)
      ..lineTo(cx, cy - 1.6)
      ..lineTo(cx, cy + 1.6)
      ..close();
    canvas.drawPath(
      westFacet,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // 5. Dynamic Sweeping Flight-Path Trajectory Vector
    // Ambient trajectory glow
    final glowPaint = Paint()
      ..color = coralColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    final flightPath = Path();
    flightPath.moveTo(cx - radius * 0.75, cy + radius * 0.45);
    flightPath.quadraticBezierTo(
      cx - radius * 0.15,
      cy - radius * 0.50,
      cx + radius * 0.70,
      cy - radius * 0.35,
    );
    canvas.drawPath(flightPath, glowPaint);

    // Crisp coral trajectory line
    final trajectoryPaint = Paint()
      ..color = coralColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(flightPath, trajectoryPaint);

    // 6. Flight Waypoint Nodes
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final nodeBorderPaint = Paint()
      ..color = coralColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Origin node (SW)
    final pStart = Offset(cx - radius * 0.75, cy + radius * 0.45);
    canvas.drawCircle(pStart, 1.8, nodePaint);
    canvas.drawCircle(pStart, 1.8, nodeBorderPaint);

    // Mid waypoint
    final pMid = Offset(cx + 0.5, cy - radius * 0.15);
    canvas.drawCircle(pMid, 1.4, nodePaint);

    // 7. Aerodynamic Vector Arrowhead at Trajectory Tip (pointing NE)
    final pEnd = Offset(cx + radius * 0.70, cy - radius * 0.35);
    const arrowAngle = -0.32; // ~-18 degrees trajectory heading
    const arrowLength = 5.2;

    final arrowPath = Path();
    arrowPath.moveTo(pEnd.dx, pEnd.dy);
    arrowPath.lineTo(
      pEnd.dx - arrowLength * math.cos(arrowAngle - 0.55),
      pEnd.dy - arrowLength * math.sin(arrowAngle - 0.55),
    );
    arrowPath.lineTo(
      pEnd.dx - (arrowLength * 0.6) * math.cos(arrowAngle),
      pEnd.dy - (arrowLength * 0.6) * math.sin(arrowAngle),
    );
    arrowPath.lineTo(
      pEnd.dx - arrowLength * math.cos(arrowAngle + 0.55),
      pEnd.dy - arrowLength * math.sin(arrowAngle + 0.55),
    );
    arrowPath.close();

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = coralColor
        ..style = PaintingStyle.fill,
    );

    // 8. Central Compass Pivot Bead (luminous coral accent)
    canvas.drawCircle(Offset(cx, cy), 2.2, Paint()..color = coralColor);
    canvas.drawCircle(Offset(cx, cy), 1.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CompassFlightPathPainter oldDelegate) {
    return oldDelegate.tealColor != tealColor ||
        oldDelegate.mintColor != mintColor ||
        oldDelegate.coralColor != coralColor ||
        oldDelegate.isDark != isDark;
  }
}
