import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Categories supported in Voyara with dedicated, meaningful icons.
enum VoyaraCategoryType {
  attraction,
  birdSanctuary,
  cultural,
  fort,
  ghat,
  lake,
  beach,
  hillStation,
  wildlife,
  adventure,
  mall,
  market,
  mausoleum,
  nationalPark,
  park,
  religiousSite,
  stepwell,
  themePark,
  village,
  warMemorial,
  museum,
  all,
  other;

  static VoyaraCategoryType fromString(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'all') {
      return VoyaraCategoryType.all;
    }
    // 1. Mall (shopping bag / store)
    if (lower.contains('mall') || lower.contains('commercial complex')) {
      return VoyaraCategoryType.mall;
    }
    // 2. Market (storefront / shop)
    if (lower.contains('market') ||
        lower.contains('bazaar') ||
        lower.contains('shop')) {
      return VoyaraCategoryType.market;
    }
    // 3. Mausoleum (monument / dome)
    if (lower.contains('mausoleum') || lower.contains('tomb')) {
      return VoyaraCategoryType.mausoleum;
    }
    // 4. National Park (forest / trees)
    if (lower.contains('national park')) {
      return VoyaraCategoryType.nationalPark;
    }
    // 5. Theme Park (ferris wheel / roller coaster)
    if (lower.contains('theme park') ||
        lower.contains('amusement') ||
        lower.contains('entertainment') ||
        lower.contains('film studio') ||
        lower.contains('race track')) {
      return VoyaraCategoryType.themePark;
    }
    // 6. War Memorial (memorial monument)
    if (lower.contains('war memorial') ||
        lower.contains('memorial') ||
        lower.contains('monument') ||
        lower.contains('landmark')) {
      return VoyaraCategoryType.warMemorial;
    }
    // 7. Stepwell (stepped well / architecture)
    if (lower.contains('stepwell') ||
        lower.contains('baori') ||
        lower.contains('bawdi')) {
      return VoyaraCategoryType.stepwell;
    }
    // 8. Village (houses)
    if (lower.contains('village') ||
        lower.contains('township') ||
        lower.contains('town') ||
        lower.contains('urban development')) {
      return VoyaraCategoryType.village;
    }
    // 9. Religious Site (temple / prayer building)
    if (lower.contains('religious') ||
        lower.contains('church') ||
        lower.contains('mosque') ||
        lower.contains('gurudwara') ||
        lower.contains('monastery') ||
        lower.contains('shrine') ||
        lower.contains('spiritual')) {
      return VoyaraCategoryType.religiousSite;
    }
    // 10. Museum & Science
    if (lower.contains('museum') ||
        lower.contains('science') ||
        lower.contains('observatory') ||
        lower.contains('government building')) {
      return VoyaraCategoryType.museum;
    }
    // 11. Park (park bench / tree)
    if (lower == 'park' ||
        lower.contains('botanical') ||
        lower.contains('garden') ||
        lower.contains('orchard') ||
        lower.contains('vineyard') ||
        lower.contains('sculpture garden')) {
      return VoyaraCategoryType.park;
    }
    // 12. Bird Sanctuary (bird)
    if (lower.contains('bird')) {
      return VoyaraCategoryType.birdSanctuary;
    }
    // 13. Cultural (temple / architecture / heritage)
    if (lower.contains('cultur') ||
        lower.contains('temple') ||
        lower.contains('architect') ||
        lower.contains('heritage') ||
        lower.contains('historic') ||
        lower.contains('rock carving') ||
        lower.contains('prehistoric')) {
      return VoyaraCategoryType.cultural;
    }
    // 14. Fort (castle / fortress)
    if (lower.contains('fort') ||
        lower.contains('castle') ||
        lower.contains('palace')) {
      return VoyaraCategoryType.fort;
    }
    // 15. Ghat (sunrise / river steps)
    if (lower.contains('ghat') ||
        lower.contains('sunrise') ||
        lower.contains('confluence')) {
      return VoyaraCategoryType.ghat;
    }
    // 16. Lake & Water
    if (lower.contains('lake') ||
        lower.contains('water') ||
        lower.contains('dam') ||
        lower.contains('aquarium')) {
      return VoyaraCategoryType.lake;
    }
    // 17. Beach (palm tree & coast)
    if (lower.contains('beach') ||
        lower.contains('palm') ||
        lower.contains('coast') ||
        lower.contains('sea') ||
        lower.contains('island') ||
        lower.contains('promenade')) {
      return VoyaraCategoryType.beach;
    }
    // 18. Hill Station (mountains)
    if (lower.contains('hill') ||
        lower.contains('mountain') ||
        lower.contains('station') ||
        lower.contains('valley') ||
        lower.contains('viewpoint') ||
        lower.contains('scenic') ||
        lower.contains('ski') ||
        lower.contains('cave')) {
      return VoyaraCategoryType.hillStation;
    }
    // 19. Wildlife (deer / fauna)
    if (lower.contains('wildlife') ||
        lower.contains('deer') ||
        lower.contains('animal') ||
        lower.contains('safari') ||
        lower.contains('fauna') ||
        lower.contains('zoo') ||
        lower.contains('sanctuary')) {
      return VoyaraCategoryType.wildlife;
    }
    // 20. Adventure (hiker)
    if (lower.contains('adventur') ||
        lower.contains('hike') ||
        lower.contains('hiker') ||
        lower.contains('trek') ||
        lower.contains('sport') ||
        lower.contains('bridge') ||
        lower.contains('border crossing')) {
      return VoyaraCategoryType.adventure;
    }
    // 21. Attraction (camera)
    if (lower.contains('attract') || lower.contains('camera')) {
      return VoyaraCategoryType.attraction;
    }
    if (lower.contains('all')) {
      return VoyaraCategoryType.all;
    }
    return VoyaraCategoryType.attraction;
  }
}

/// A custom vector icon widget rendering distinct category iconography with
/// subtle teal, mint, and muted-orange accents tailored for Voyara's dark theme.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.isSelected = false,
    this.isDark = true,
    this.size = 24.0,
  });

  final String category;
  final bool isSelected;
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final type = VoyaraCategoryType.fromString(category);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CategoryIconPainter(
          type: type,
          isSelected: isSelected,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _CategoryIconPainter extends CustomPainter {
  _CategoryIconPainter({
    required this.type,
    required this.isSelected,
    required this.isDark,
  });

  final VoyaraCategoryType type;
  final bool isSelected;
  final bool isDark;

  // Curated palette matching Voyara theme
  Color get mint => isSelected ? Colors.white : const Color(0xFF2EC4B6);
  Color get teal =>
      isSelected ? const Color(0xFFE2F6F4) : const Color(0xFF38B29C);
  Color get darkTeal =>
      isSelected ? const Color(0xFF092929) : const Color(0xFF143838);
  Color get orange =>
      isSelected ? const Color(0xFFFFD4C4) : const Color(0xFFF26E42);
  Color get gold =>
      isSelected ? const Color(0xFFFFE8A3) : const Color(0xFFE5A93C);
  Color get subtleTeal =>
      isSelected ? const Color(0x80FFFFFF) : const Color(0xFF1B5958);
  Color get highlight => isSelected
      ? Colors.white
      : (isDark ? Colors.white : const Color(0xFF142121));

  @override
  void paint(Canvas canvas, Size size) {
    // Scale coordinate space uniformly from 24x24 canvas to target size
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    switch (type) {
      case VoyaraCategoryType.attraction:
        _drawAttraction(canvas);
        break;
      case VoyaraCategoryType.birdSanctuary:
        _drawBirdSanctuary(canvas);
        break;
      case VoyaraCategoryType.cultural:
        _drawCultural(canvas);
        break;
      case VoyaraCategoryType.fort:
        _drawFort(canvas);
        break;
      case VoyaraCategoryType.ghat:
        _drawGhat(canvas);
        break;
      case VoyaraCategoryType.lake:
        _drawLake(canvas);
        break;
      case VoyaraCategoryType.beach:
        _drawBeach(canvas);
        break;
      case VoyaraCategoryType.hillStation:
        _drawHillStation(canvas);
        break;
      case VoyaraCategoryType.wildlife:
        _drawWildlife(canvas);
        break;
      case VoyaraCategoryType.adventure:
        _drawAdventure(canvas);
        break;
      case VoyaraCategoryType.mall:
        _drawMall(canvas);
        break;
      case VoyaraCategoryType.market:
        _drawMarket(canvas);
        break;
      case VoyaraCategoryType.mausoleum:
        _drawMausoleum(canvas);
        break;
      case VoyaraCategoryType.nationalPark:
        _drawNationalPark(canvas);
        break;
      case VoyaraCategoryType.park:
        _drawPark(canvas);
        break;
      case VoyaraCategoryType.religiousSite:
        _drawReligiousSite(canvas);
        break;
      case VoyaraCategoryType.stepwell:
        _drawStepwell(canvas);
        break;
      case VoyaraCategoryType.themePark:
        _drawThemePark(canvas);
        break;
      case VoyaraCategoryType.village:
        _drawVillage(canvas);
        break;
      case VoyaraCategoryType.warMemorial:
        _drawWarMemorial(canvas);
        break;
      case VoyaraCategoryType.museum:
        _drawMuseum(canvas);
        break;
      case VoyaraCategoryType.all:
      case VoyaraCategoryType.other:
        _drawCompass(canvas);
        break;
    }

    canvas.restore();
  }

  /// 1. Attraction: Camera with subtle sparkle star
  void _drawAttraction(Canvas canvas) {
    final bodyPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;

    // Camera body
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.5, 7.5, 19.0, 13.0),
      const Radius.circular(2.8),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Top viewfinder bump
    final topBump = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6.5, 5.2, 5.5, 2.5),
      const Radius.circular(1.2),
    );
    canvas.drawRRect(topBump, bodyPaint);

    // Outer lens ring
    final lensOuterPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.0, 14.0), 4.3, lensOuterPaint);

    // Inner lens glass
    final lensInnerPaint = Paint()
      ..color = isSelected ? const Color(0xFF2EC4B6) : teal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.0, 14.0), 2.4, lensInnerPaint);

    // Lens reflection dot
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(13.0, 13.0), 0.75, dotPaint);

    // Flash indicator dot
    final flashPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(18.2, 10.2), 1.1, flashPaint);

    // Sparkle / star at top-right
    _drawSparkle(canvas, const Offset(19.0, 3.8), 2.8, orange);
  }

  /// 2. Bird Sanctuary: Songbird perched on branch with warm breast accent
  void _drawBirdSanctuary(Canvas canvas) {
    // Perch branch
    final branchPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(3.5, 19.0),
      const Offset(20.5, 19.0),
      branchPaint,
    );

    // Tiny branch leaf
    final leafPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    final leafPath = Path()
      ..moveTo(6.0, 19.0)
      ..quadraticBezierTo(7.5, 16.5, 9.5, 17.5)
      ..quadraticBezierTo(8.0, 19.5, 6.0, 19.0);
    canvas.drawPath(leafPath, leafPaint);

    // Bird legs
    final legPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(11.5, 16.5),
      const Offset(11.5, 19.0),
      legPaint,
    );
    canvas.drawLine(
      const Offset(13.5, 16.5),
      const Offset(13.5, 19.0),
      legPaint,
    );

    // Bird main body & tail
    final bodyPath = Path()
      ..moveTo(4.0, 17.5)
      ..lineTo(8.5, 15.0)
      ..quadraticBezierTo(10.5, 9.5, 14.0, 7.5)
      ..lineTo(15.5, 7.5)
      ..quadraticBezierTo(16.5, 10.0, 15.5, 13.0)
      ..quadraticBezierTo(13.5, 17.0, 9.0, 17.0)
      ..lineTo(4.0, 17.5)
      ..close();

    final bodyPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // Head
    final headPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(14.5, 7.0), 2.8, headPaint);

    // Warm breast / belly accent
    final breastPath = Path()
      ..moveTo(13.5, 8.5)
      ..quadraticBezierTo(16.5, 10.5, 15.0, 14.0)
      ..quadraticBezierTo(13.0, 16.5, 10.5, 16.5)
      ..quadraticBezierTo(12.5, 12.0, 13.5, 8.5)
      ..close();
    final breastPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(breastPath, breastPaint);

    // Wing
    final wingPath = Path()
      ..moveTo(9.5, 11.5)
      ..quadraticBezierTo(13.0, 12.0, 12.0, 15.0)
      ..quadraticBezierTo(9.0, 16.5, 5.5, 17.2)
      ..quadraticBezierTo(7.5, 13.5, 9.5, 11.5)
      ..close();
    final wingPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawPath(wingPath, wingPaint);

    // Beak
    final beakPath = Path()
      ..moveTo(16.8, 6.2)
      ..lineTo(20.5, 7.0)
      ..lineTo(16.8, 7.8)
      ..close();
    final beakPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(beakPath, beakPaint);

    // Eye dot
    final eyePaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(15.2, 6.4), 0.65, eyePaint);
  }

  /// 3. Cultural: Grand Indian temple shikhara with kalasha & pillared arch
  void _drawCultural(Canvas canvas) {
    final warmOrangePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;

    // Mandapa base plinth
    final baseRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.0, 17.5, 18.0, 3.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(baseRect, warmOrangePaint);

    // Lower temple walls with entrance arch
    final wallPath = Path()
      ..moveTo(4.5, 17.5)
      ..lineTo(4.5, 13.0)
      ..lineTo(19.5, 13.0)
      ..lineTo(19.5, 17.5)
      ..close();
    canvas.drawPath(wallPath, warmOrangePaint);

    // Arched portal doorway (sanctum entrance)
    final doorPath = Path()
      ..moveTo(10.2, 17.5)
      ..lineTo(10.2, 14.5)
      ..arcToPoint(
        const Offset(13.8, 14.5),
        radius: const Radius.circular(1.8),
        clockwise: true,
      )
      ..lineTo(13.8, 17.5)
      ..close();
    final doorPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(doorPath, doorPaint);

    // Side tiered pavilion roofs
    final leftSideRoof = Path()
      ..moveTo(3.5, 13.0)
      ..lineTo(7.5, 10.0)
      ..lineTo(8.5, 13.0)
      ..close();
    final rightSideRoof = Path()
      ..moveTo(15.5, 13.0)
      ..lineTo(16.5, 10.0)
      ..lineTo(20.5, 13.0)
      ..close();
    canvas.drawPath(leftSideRoof, warmOrangePaint);
    canvas.drawPath(rightSideRoof, warmOrangePaint);

    // Central tiered Shikhara (spire)
    final shikharaPath = Path()
      ..moveTo(7.0, 13.0)
      ..quadraticBezierTo(9.0, 8.5, 10.8, 4.5)
      ..lineTo(13.2, 4.5)
      ..quadraticBezierTo(15.0, 8.5, 17.0, 13.0)
      ..close();
    canvas.drawPath(shikharaPath, warmOrangePaint);

    // Horizontal ridge lines on shikhara (amalaka rings)
    final linePaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(
      const Offset(8.2, 10.5),
      const Offset(15.8, 10.5),
      linePaint,
    );
    canvas.drawLine(const Offset(9.4, 7.8), const Offset(14.6, 7.8), linePaint);

    // Kalasha & finial pot at apex
    final kalashPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.0, 3.8), 1.2, kalashPaint);

    // Spire pinnacle needle
    final needlePaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(12.0, 3.8),
      const Offset(12.0, 2.0),
      needlePaint,
    );
  }

  /// 4. Fort: Sandstone fortress with crenelated towers and battlements
  void _drawFort(Canvas canvas) {
    final fortPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;

    // Left tower
    final leftTower = Path()
      ..moveTo(2.5, 20.0)
      ..lineTo(2.5, 6.0)
      ..lineTo(4.0, 6.0)
      ..lineTo(4.0, 7.5)
      ..lineTo(5.5, 7.5)
      ..lineTo(5.5, 6.0)
      ..lineTo(7.5, 6.0)
      ..lineTo(7.5, 20.0)
      ..close();
    canvas.drawPath(leftTower, fortPaint);

    // Right tower
    final rightTower = Path()
      ..moveTo(16.5, 20.0)
      ..lineTo(16.5, 6.0)
      ..lineTo(18.5, 6.0)
      ..lineTo(18.5, 7.5)
      ..lineTo(20.0, 7.5)
      ..lineTo(20.0, 6.0)
      ..lineTo(21.5, 6.0)
      ..lineTo(21.5, 20.0)
      ..close();
    canvas.drawPath(rightTower, fortPaint);

    // Center curtain wall with crenellations
    final centerWall = Path()
      ..moveTo(7.5, 20.0)
      ..lineTo(7.5, 9.5)
      ..lineTo(9.0, 9.5)
      ..lineTo(9.0, 11.0)
      ..lineTo(10.5, 11.0)
      ..lineTo(10.5, 9.5)
      ..lineTo(13.5, 9.5)
      ..lineTo(13.5, 11.0)
      ..lineTo(15.0, 11.0)
      ..lineTo(15.0, 9.5)
      ..lineTo(16.5, 9.5)
      ..lineTo(16.5, 20.0)
      ..close();
    canvas.drawPath(centerWall, fortPaint);

    // Fortress arched portal gateway
    final gatePath = Path()
      ..moveTo(9.8, 20.0)
      ..lineTo(9.8, 14.5)
      ..arcToPoint(
        const Offset(14.2, 14.5),
        radius: const Radius.circular(2.2),
        clockwise: true,
      )
      ..lineTo(14.2, 20.0)
      ..close();
    final gatePaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(gatePath, gatePaint);

    // Triangular flag on left tower
    final flagPath = Path()
      ..moveTo(5.0, 6.0)
      ..lineTo(5.0, 2.5)
      ..lineTo(8.5, 4.0)
      ..lineTo(5.0, 5.5)
      ..close();
    final flagPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(flagPath, flagPaint);

    // Wall embrasure slits
    final slitPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(5.0, 10.5),
      const Offset(5.0, 13.0),
      slitPaint,
    );
    canvas.drawLine(
      const Offset(19.0, 10.5),
      const Offset(19.0, 13.0),
      slitPaint,
    );
  }

  /// 5. Ghat: Stepped river ghat with radiant sunrise over water ripples
  void _drawGhat(Canvas canvas) {
    // Stepped stone ghat descending on left
    final stepsPath = Path()
      ..moveTo(2.5, 9.0)
      ..lineTo(5.5, 9.0)
      ..lineTo(5.5, 12.0)
      ..lineTo(8.5, 12.0)
      ..lineTo(8.5, 15.0)
      ..lineTo(11.5, 15.0)
      ..lineTo(11.5, 18.0)
      ..lineTo(14.5, 18.0)
      ..lineTo(14.5, 20.5)
      ..lineTo(2.5, 20.5)
      ..close();
    final stepsPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(stepsPath, stepsPaint);

    // Step edge highlights
    final stepEdgePaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(2.5, 9.0),
      const Offset(5.5, 9.0),
      stepEdgePaint,
    );
    canvas.drawLine(
      const Offset(5.5, 12.0),
      const Offset(8.5, 12.0),
      stepEdgePaint,
    );
    canvas.drawLine(
      const Offset(8.5, 15.0),
      const Offset(11.5, 15.0),
      stepEdgePaint,
    );
    canvas.drawLine(
      const Offset(11.5, 18.0),
      const Offset(14.5, 18.0),
      stepEdgePaint,
    );

    // Rising Sun above water
    final sunCenter = const Offset(16.5, 10.5);
    final sunPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 4.2, sunPaint);

    // Radiant sun rays
    final rayPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final rayOffsets = [
      [const Offset(16.5, 5.0), const Offset(16.5, 3.0)],
      [const Offset(12.5, 6.8), const Offset(10.8, 5.2)],
      [const Offset(20.5, 6.8), const Offset(22.2, 5.2)],
      [const Offset(21.8, 10.5), const Offset(23.5, 10.5)],
    ];
    for (final pair in rayOffsets) {
      canvas.drawLine(pair[0], pair[1], rayPaint);
    }

    // River water waves at base
    final wavePaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final wave1 = Path()
      ..moveTo(11.5, 17.5)
      ..quadraticBezierTo(14.0, 16.5, 16.5, 17.5)
      ..quadraticBezierTo(19.0, 18.5, 21.5, 17.5);
    canvas.drawPath(wave1, wavePaint);

    final wave2 = Path()
      ..moveTo(14.5, 20.0)
      ..quadraticBezierTo(17.0, 19.0, 19.5, 20.0)
      ..quadraticBezierTo(21.0, 20.8, 22.5, 20.0);
    canvas.drawPath(wave2, wavePaint);
  }

  /// 6. Lake: Serene undulating water waves with alpine sun & mountain horizon
  void _drawLake(Canvas canvas) {
    // Mountain horizon silhouettes in background
    final hillPath = Path()
      ..moveTo(2.0, 13.5)
      ..quadraticBezierTo(7.0, 8.5, 11.5, 11.5)
      ..quadraticBezierTo(16.0, 8.0, 22.0, 13.5)
      ..close();
    final hillPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(hillPath, hillPaint);

    // Golden sun rising over the lake
    final sunPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.0, 6.8), 3.0, sunPaint);

    // Water wave ripples
    final wave1Paint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final wave1 = Path()
      ..moveTo(3.0, 13.5)
      ..quadraticBezierTo(7.5, 12.0, 12.0, 13.5)
      ..quadraticBezierTo(16.5, 15.0, 21.0, 13.5);
    canvas.drawPath(wave1, wave1Paint);

    final wave2Paint = Paint()
      ..color = teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final wave2 = Path()
      ..moveTo(4.5, 17.0)
      ..quadraticBezierTo(9.0, 18.5, 13.5, 17.0)
      ..quadraticBezierTo(17.5, 15.5, 20.0, 17.0);
    canvas.drawPath(wave2, wave2Paint);

    final wave3Paint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final wave3 = Path()
      ..moveTo(6.5, 20.5)
      ..quadraticBezierTo(11.0, 19.5, 15.5, 20.5)
      ..quadraticBezierTo(17.5, 21.2, 19.0, 20.5);
    canvas.drawPath(wave3, wave3Paint);
  }

  /// 7. Beach: Slender tropical palm tree on coastal sandy shore
  void _drawBeach(Canvas canvas) {
    // Shoreline sand dune
    final sandPath = Path()
      ..moveTo(8.0, 21.0)
      ..quadraticBezierTo(15.0, 19.0, 22.0, 21.0)
      ..close();
    final sandPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawPath(sandPath, sandPaint);

    // Ocean water ripple on left
    final wavePaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final wavePath = Path()
      ..moveTo(2.5, 20.5)
      ..quadraticBezierTo(5.0, 19.0, 7.5, 20.5);
    canvas.drawPath(wavePath, wavePaint);

    // Curved palm tree trunk
    final trunkPath = Path()
      ..moveTo(14.5, 20.5)
      ..quadraticBezierTo(14.0, 15.0, 11.5, 8.5)
      ..lineTo(9.8, 8.8)
      ..quadraticBezierTo(12.5, 15.0, 12.8, 20.5)
      ..close();
    final trunkPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(trunkPath, trunkPaint);

    // Trunk segment rings
    final ringPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(
      const Offset(12.3, 16.5),
      const Offset(14.1, 16.0),
      ringPaint,
    );
    canvas.drawLine(
      const Offset(11.3, 12.5),
      const Offset(13.1, 12.0),
      ringPaint,
    );

    // Palm fronds
    final frondPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final crown = const Offset(10.5, 8.5);

    // Frond 1: Left & down
    final f1 = Path()
      ..moveTo(crown.dx, crown.dy)
      ..quadraticBezierTo(5.5, 8.5, 2.5, 12.0);
    canvas.drawPath(f1, frondPaint);

    // Frond 2: Top-left
    final f2 = Path()
      ..moveTo(crown.dx, crown.dy)
      ..quadraticBezierTo(5.5, 4.5, 3.5, 5.5);
    canvas.drawPath(f2, frondPaint);

    // Frond 3: Top-right arch
    final f3 = Path()
      ..moveTo(crown.dx, crown.dy)
      ..quadraticBezierTo(12.5, 3.0, 15.5, 3.5);
    canvas.drawPath(f3, frondPaint);

    // Frond 4: Right & slight down
    final f4 = Path()
      ..moveTo(crown.dx, crown.dy)
      ..quadraticBezierTo(17.5, 6.0, 21.0, 8.0);
    canvas.drawPath(f4, frondPaint);

    // Frond 5: Drooping right
    final f5 = Path()
      ..moveTo(crown.dx, crown.dy)
      ..quadraticBezierTo(17.0, 11.5, 19.5, 14.5);
    canvas.drawPath(f5, frondPaint);

    // Coconuts under fronds
    final nutPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(10.0, 9.8), 1.0, nutPaint);
    canvas.drawCircle(const Offset(11.8, 9.8), 1.0, nutPaint);
  }

  /// 8. Hill Station: Twin snowcapped mountain peaks with pine forest
  void _drawHillStation(Canvas canvas) {
    // Secondary left mountain peak
    final leftMountain = Path()
      ..moveTo(1.5, 19.5)
      ..lineTo(7.0, 9.0)
      ..lineTo(13.0, 19.5)
      ..close();
    final leftMountainPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftMountain, leftMountainPaint);

    // Left peak snowcap
    final leftSnow = Path()
      ..moveTo(7.0, 9.0)
      ..lineTo(5.0, 12.5)
      ..lineTo(6.5, 12.0)
      ..lineTo(8.5, 12.5)
      ..close();
    final snowPaint = Paint()
      ..color = highlight
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftSnow, snowPaint);

    // Main majestic mountain peak
    final mainMountain = Path()
      ..moveTo(4.5, 19.5)
      ..lineTo(13.5, 3.5)
      ..lineTo(22.5, 19.5)
      ..close();
    final mainMountainPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainMountain, mainMountainPaint);

    // Main mountain snowcap
    final mainSnow = Path()
      ..moveTo(13.5, 3.5)
      ..lineTo(10.0, 9.5)
      ..lineTo(12.0, 8.8)
      ..lineTo(13.5, 10.0)
      ..lineTo(15.5, 8.8)
      ..lineTo(17.0, 9.5)
      ..close();
    canvas.drawPath(mainSnow, snowPaint);

    // Mountain central ridge shade
    final ridgePath = Path()
      ..moveTo(13.5, 3.5)
      ..lineTo(13.5, 19.5)
      ..lineTo(22.5, 19.5)
      ..close();
    final ridgePaint = Paint()
      ..color = darkTeal.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(ridgePath, ridgePaint);

    // Foreground pine trees
    _drawPineTree(canvas, const Offset(5.5, 15.0), 5.0, mint);
    _drawPineTree(canvas, const Offset(19.0, 14.5), 5.5, mint);
    _drawPineTree(canvas, const Offset(16.0, 16.5), 4.0, subtleTeal);
  }

  /// 9. Wildlife: Stag/deer with majestic antlers standing alert
  void _drawWildlife(Canvas canvas) {
    // Forest pine tree in background on left
    _drawPineTree(canvas, const Offset(5.0, 14.0), 6.5, subtleTeal);

    // Deer body & neck silhouette
    final deerPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;

    final deerPath = Path()
      ..moveTo(7.5, 20.0)
      ..lineTo(9.5, 16.0)
      ..quadraticBezierTo(9.0, 13.0, 11.5, 10.0)
      ..lineTo(13.5, 7.5)
      ..lineTo(17.0, 9.2)
      ..lineTo(15.5, 11.2)
      ..quadraticBezierTo(14.0, 14.0, 13.5, 17.0)
      ..lineTo(14.0, 20.0)
      ..lineTo(12.2, 20.0)
      ..lineTo(12.0, 17.5)
      ..lineTo(9.0, 17.5)
      ..lineTo(8.5, 20.0)
      ..close();
    canvas.drawPath(deerPath, deerPaint);

    // Deer alert ear
    final earPath = Path()
      ..moveTo(12.0, 7.5)
      ..quadraticBezierTo(9.5, 6.0, 9.0, 7.5)
      ..lineTo(11.5, 8.5)
      ..close();
    canvas.drawPath(earPath, deerPaint);

    // Branching Antlers
    final antlerPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Right main antler
    final rightAntler = Path()
      ..moveTo(12.5, 7.0)
      ..quadraticBezierTo(13.5, 4.0, 16.0, 2.0);
    canvas.drawPath(rightAntler, antlerPaint);
    canvas.drawLine(
      const Offset(13.2, 5.0),
      const Offset(15.2, 4.2),
      antlerPaint,
    );
    canvas.drawLine(
      const Offset(14.5, 3.2),
      const Offset(17.0, 3.0),
      antlerPaint,
    );

    // Left main antler
    final leftAntler = Path()
      ..moveTo(12.0, 7.0)
      ..quadraticBezierTo(10.5, 4.0, 7.5, 2.2);
    canvas.drawPath(leftAntler, antlerPaint);
    canvas.drawLine(
      const Offset(11.2, 5.0),
      const Offset(9.2, 4.5),
      antlerPaint,
    );
    canvas.drawLine(
      const Offset(9.5, 3.5),
      const Offset(7.8, 3.8),
      antlerPaint,
    );

    // Eye dot
    final eyePaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(14.5, 8.5), 0.6, eyePaint);
  }

  /// 10. Adventure: Hiker trekking with backpack and walking stick
  void _drawAdventure(Canvas canvas) {
    // Mountain slope incline
    final slopePaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(2.0, 21.0),
      const Offset(22.0, 17.0),
      slopePaint,
    );

    // Trekker cap & head
    final headPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.5, 5.2), 1.8, headPaint);

    // Cap visor
    final capPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(12.5, 4.5), const Offset(15.2, 4.8), capPaint);

    // Backpack on back
    final packRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7.8, 8.0, 3.4, 5.0),
      const Radius.circular(1.2),
    );
    final packPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawRRect(packRect, packPaint);

    // Torso
    final bodyPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(12.2, 7.0),
      const Offset(11.0, 13.0),
      bodyPaint,
    );

    // Legs striding
    final legPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Forward stepping leg
    final forwardLeg = Path()
      ..moveTo(11.0, 13.0)
      ..lineTo(13.8, 15.5)
      ..lineTo(15.0, 18.2);
    canvas.drawPath(forwardLeg, legPaint);

    // Rear trailing leg
    final backLeg = Path()
      ..moveTo(11.0, 13.0)
      ..lineTo(9.2, 16.0)
      ..lineTo(7.5, 20.0);
    canvas.drawPath(backLeg, legPaint);

    // Arm and trekking pole
    final polePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(14.0, 10.0),
      const Offset(17.8, 18.0),
      polePaint,
    );

    // Arm
    final armPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(11.5, 8.5),
      const Offset(14.0, 10.0),
      armPaint,
    );
  }

  /// 11. Mall: Designer shopping bag with handle and star logo
  void _drawMall(Canvas canvas) {
    // Shopping Bag Body
    final bagPath = Path()
      ..moveTo(5.5, 9.0)
      ..lineTo(18.5, 9.0)
      ..lineTo(19.5, 19.5)
      ..quadraticBezierTo(19.8, 20.5, 18.5, 20.5)
      ..lineTo(5.5, 20.5)
      ..quadraticBezierTo(4.2, 20.5, 4.5, 19.5)
      ..close();

    final bagPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawPath(bagPath, bagPaint);

    // Bag handles (looped up)
    final handlePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final handlePath = Path()
      ..moveTo(9.0, 9.0)
      ..cubicTo(9.0, 4.5, 15.0, 4.5, 15.0, 9.0);
    canvas.drawPath(handlePath, handlePaint);

    // Decorative fold crease on bag
    final creasePaint = Paint()
      ..color = darkTeal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(12.0, 9.0),
      const Offset(12.0, 20.5),
      creasePaint,
    );

    // Boutique star on bag
    _drawSparkle(canvas, const Offset(12.0, 14.5), 2.2, orange);
  }

  /// 12. Market: Storefront shop with striped awning and entrance
  void _drawMarket(Canvas canvas) {
    // Store Base Building
    final wallRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.5, 10.0, 17.0, 10.5),
      const Radius.circular(1.0),
    );
    final wallPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.fill;
    canvas.drawRRect(wallRect, wallPaint);

    // Store window (display)
    final windowRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.2, 12.0, 5.0, 5.0),
      const Radius.circular(1.0),
    );
    final windowPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawRRect(windowRect, windowPaint);

    // Store open door
    final doorPath = Path()
      ..moveTo(12.5, 20.5)
      ..lineTo(12.5, 13.0)
      ..arcToPoint(
        const Offset(17.5, 13.0),
        radius: const Radius.circular(2.5),
        clockwise: true,
      )
      ..lineTo(17.5, 20.5)
      ..close();
    final doorPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(doorPath, doorPaint);

    // Striped Awning across top
    final awningPaintOrange = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    final awningPaintMint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;

    // Awning valence segments
    final scallops = [
      [2.5, 7.25, awningPaintOrange],
      [7.25, 12.0, awningPaintMint],
      [12.0, 16.75, awningPaintOrange],
      [16.75, 21.5, awningPaintMint],
    ];
    for (final s in scallops) {
      final start = s[0] as double;
      final end = s[1] as double;
      final paint = s[2] as Paint;
      final mid = (start + end) / 2;
      final scPath = Path()
        ..moveTo(start, 5.0)
        ..lineTo(end, 5.0)
        ..lineTo(end, 9.5)
        ..quadraticBezierTo(mid, 11.2, start, 9.5)
        ..close();
      canvas.drawPath(scPath, paint);
    }
  }

  /// 13. Mausoleum: Grand Taj-style dome, archway, and minarets
  void _drawMausoleum(Canvas canvas) {
    // Base stepped terrace
    final plinth = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.5, 17.5, 19.0, 3.2),
      const Radius.circular(1.0),
    );
    final plinthPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawRRect(plinth, plinthPaint);

    // Main chamber facade
    final facadePath = Path()
      ..moveTo(6.5, 17.5)
      ..lineTo(6.5, 11.5)
      ..lineTo(17.5, 11.5)
      ..lineTo(17.5, 17.5)
      ..close();
    final facadePaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawPath(facadePath, facadePaint);

    // Central Grand Arched Iwan
    final iwanPath = Path()
      ..moveTo(9.5, 17.5)
      ..lineTo(9.5, 13.5)
      ..quadraticBezierTo(12.0, 12.0, 14.5, 13.5)
      ..lineTo(14.5, 17.5)
      ..close();
    final iwanPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(iwanPath, iwanPaint);

    // Majestic Bulbous Onion Dome
    final domePath = Path()
      ..moveTo(8.5, 11.5)
      ..cubicTo(7.5, 8.5, 11.0, 5.0, 12.0, 3.5)
      ..cubicTo(13.0, 5.0, 16.5, 8.5, 15.5, 11.5)
      ..close();
    final domePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(domePath, domePaint);

    // Finial needle atop dome
    final needlePaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(12.0, 3.5),
      const Offset(12.0, 1.8),
      needlePaint,
    );

    // Side minaret spires
    final minaretPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(3.5, 9.5, 1.8, 8.0), minaretPaint);
    canvas.drawCircle(const Offset(4.4, 8.5), 1.3, minaretPaint);
    canvas.drawRect(const Rect.fromLTWH(18.7, 9.5, 1.8, 8.0), minaretPaint);
    canvas.drawCircle(const Offset(19.6, 8.5), 1.3, minaretPaint);
  }

  /// 14. National Park: Dense forest canopy, pine trees, and sun
  void _drawNationalPark(Canvas canvas) {
    // Forest groundline
    final groundPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(2.0, 20.5),
      const Offset(22.0, 20.5),
      groundPaint,
    );

    // Background Pine tree on left
    _drawPineTree(canvas, const Offset(5.5, 16.0), 6.5, subtleTeal);

    // Center Large Deciduous / Canopy Tree
    final trunkPath = Path()
      ..moveTo(12.0, 20.5)
      ..lineTo(12.0, 13.0)
      ..lineTo(13.5, 13.0)
      ..lineTo(13.5, 20.5)
      ..close();
    final trunkPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(trunkPath, trunkPaint);

    // Lush rounded cloud canopy
    final canopyPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.8, 8.5), 4.6, canopyPaint);
    canvas.drawCircle(const Offset(9.8, 10.5), 3.4, canopyPaint);
    canvas.drawCircle(const Offset(15.5, 10.5), 3.4, canopyPaint);

    // Foreground Pine tree on right
    _drawPineTree(canvas, const Offset(19.0, 16.5), 7.5, teal);

    // Sun peek in the sky
    final sunPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(5.0, 5.5), 2.2, sunPaint);
  }

  /// 15. Park: Leafy park shade tree with park bench
  void _drawPark(Canvas canvas) {
    // Ground lawn line
    final groundPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(2.0, 20.5),
      const Offset(22.0, 20.5),
      groundPaint,
    );

    // Shady Tree on right
    final trunkPath = Path()
      ..moveTo(16.5, 20.5)
      ..quadraticBezierTo(16.0, 14.0, 14.5, 10.0)
      ..lineTo(16.0, 10.0)
      ..quadraticBezierTo(17.5, 14.0, 18.0, 20.5)
      ..close();
    final trunkPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(trunkPath, trunkPaint);

    // Tree leafy crown
    final leafPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(16.0, 6.5), 4.5, leafPaint);
    canvas.drawCircle(const Offset(12.8, 8.0), 3.2, leafPaint);
    canvas.drawCircle(const Offset(19.2, 8.0), 3.2, leafPaint);

    // Park Bench on left
    final benchWoodPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Backrest slat
    canvas.drawLine(
      const Offset(4.0, 13.0),
      const Offset(10.5, 13.0),
      benchWoodPaint,
    );
    // Seat slat
    canvas.drawLine(
      const Offset(3.5, 16.0),
      const Offset(11.0, 16.0),
      benchWoodPaint,
    );

    // Bench iron legs
    final legPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(4.8, 13.0), const Offset(4.2, 20.5), legPaint);
    canvas.drawLine(
      const Offset(9.8, 13.0),
      const Offset(10.2, 20.5),
      legPaint,
    );
  }

  /// 16. Religious Site: Sacred temple / prayer building with flame
  void _drawReligiousSite(Canvas canvas) {
    final sacredPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;

    // Plinth base
    final plinth = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.0, 18.0, 18.0, 2.5),
      const Radius.circular(0.8),
    );
    canvas.drawRRect(plinth, sacredPaint);

    // Pillars / Columns
    final pillarPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(5.0, 12.5, 1.8, 5.5), pillarPaint);
    canvas.drawRect(const Rect.fromLTWH(17.2, 12.5, 1.8, 5.5), pillarPaint);

    // Central Archway
    final archPath = Path()
      ..moveTo(8.5, 18.0)
      ..lineTo(8.5, 14.5)
      ..arcToPoint(
        const Offset(15.5, 14.5),
        radius: const Radius.circular(3.5),
        clockwise: true,
      )
      ..lineTo(15.5, 18.0)
      ..close();
    final archPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(archPath, archPaint);

    // Sacred central Diya / Flame
    final flamePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    final flamePath = Path()
      ..moveTo(12.0, 14.0)
      ..quadraticBezierTo(13.2, 15.5, 12.0, 17.0)
      ..quadraticBezierTo(10.8, 15.5, 12.0, 14.0)
      ..close();
    canvas.drawPath(flamePath, flamePaint);

    // Spire / Prayer Dome
    final domePath = Path()
      ..moveTo(4.0, 12.5)
      ..lineTo(7.5, 9.0)
      ..lineTo(12.0, 4.0)
      ..lineTo(16.5, 9.0)
      ..lineTo(20.0, 12.5)
      ..close();
    final domePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(domePath, domePaint);

    // Kalasha & sacred finial
    canvas.drawCircle(const Offset(12.0, 3.5), 1.2, sacredPaint);
    final finialLine = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(12.0, 3.5),
      const Offset(12.0, 1.8),
      finialLine,
    );
  }

  /// 17. Stepwell: Stepped well architecture (Baori) with descending terraces & pool
  void _drawStepwell(Canvas canvas) {
    final stonePaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;

    // Top outer parapet
    final topParapet = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.5, 3.5, 19.0, 2.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(topParapet, stonePaint);

    // Tier 1 descending terraces
    final stepPaint1 = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    final tier1Left = Path()
      ..moveTo(3.5, 6.0)
      ..lineTo(8.5, 6.0)
      ..lineTo(6.5, 10.0)
      ..lineTo(3.5, 10.0)
      ..close();
    final tier1Right = Path()
      ..moveTo(15.5, 6.0)
      ..lineTo(20.5, 6.0)
      ..lineTo(20.5, 10.0)
      ..lineTo(17.5, 10.0)
      ..close();
    canvas.drawPath(tier1Left, stepPaint1);
    canvas.drawPath(tier1Right, stepPaint1);

    // Tier 2 descending steps
    final stepPaint2 = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    final tier2Left = Path()
      ..moveTo(5.5, 10.0)
      ..lineTo(9.5, 10.0)
      ..lineTo(8.0, 14.5)
      ..lineTo(5.5, 14.5)
      ..close();
    final tier2Right = Path()
      ..moveTo(14.5, 10.0)
      ..lineTo(18.5, 10.0)
      ..lineTo(18.5, 14.5)
      ..lineTo(16.0, 14.5)
      ..close();
    canvas.drawPath(tier2Left, stepPaint2);
    canvas.drawPath(tier2Right, stepPaint2);

    // Tier 3 lower stairs
    final tier3Left = Path()
      ..moveTo(7.0, 14.5)
      ..lineTo(10.0, 14.5)
      ..lineTo(9.5, 18.0)
      ..lineTo(7.0, 18.0)
      ..close();
    final tier3Right = Path()
      ..moveTo(14.0, 14.5)
      ..lineTo(17.0, 14.5)
      ..lineTo(17.0, 18.0)
      ..lineTo(14.5, 18.0)
      ..close();
    canvas.drawPath(tier3Left, stepPaint1);
    canvas.drawPath(tier3Right, stepPaint1);

    // Deep water pool at bottom
    final waterPool = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8.0, 17.5, 8.0, 3.5),
      const Radius.circular(1.0),
    );
    final waterPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawRRect(waterPool, waterPaint);

    // Water ripple
    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(
      const Offset(9.5, 19.2),
      const Offset(14.5, 19.2),
      ripplePaint,
    );
  }

  /// 18. Theme Park: Amusement Ferris wheel with cabins & hub
  void _drawThemePark(Canvas canvas) {
    final center = const Offset(12.0, 11.0);
    const radius = 7.5;

    // A-frame base support legs
    final supportPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, const Offset(6.0, 20.5), supportPaint);
    canvas.drawLine(center, const Offset(18.0, 20.5), supportPaint);
    canvas.drawLine(
      const Offset(8.0, 18.0),
      const Offset(16.0, 18.0),
      supportPaint,
    );

    // Outer wheel rim
    final wheelPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(center, radius, wheelPaint);

    // 6 Radiating spokes
    final spokePaint = Paint()
      ..color = mint.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(dx, dy), spokePaint);
    }

    // Center hub
    final hubPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.5, hubPaint);

    // Gondola cabins around wheel
    final cabinPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final cx = center.dx + radius * math.cos(angle);
      final cy = center.dy + radius * math.sin(angle);
      final cabinRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 2.8, height: 2.8),
        const Radius.circular(0.8),
      );
      canvas.drawRRect(cabinRect, cabinPaint);
    }
  }

  /// 19. Village: Quaint cluster of village cottages / houses
  void _drawVillage(Canvas canvas) {
    // Ground path line
    final groundPaint = Paint()
      ..color = subtleTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(2.0, 20.5),
      const Offset(22.0, 20.5),
      groundPaint,
    );

    // Cottage 2 in background on right
    final bgRoof = Path()
      ..moveTo(12.0, 13.0)
      ..lineTo(16.5, 8.5)
      ..lineTo(21.0, 13.0)
      ..close();
    final bgRoofPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawPath(bgRoof, bgRoofPaint);

    final bgWall = const Rect.fromLTWH(13.0, 13.0, 7.0, 7.5);
    final bgWallPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.fill;
    canvas.drawRect(bgWall, bgWallPaint);

    final bgWindowPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(15.2, 14.5, 2.4, 2.4), bgWindowPaint);

    // Cottage 1 in foreground on left
    final fgWall = const Rect.fromLTWH(3.5, 11.5, 8.5, 9.0);
    final fgWallPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawRect(fgWall, fgWallPaint);

    final fgRoof = Path()
      ..moveTo(2.2, 11.5)
      ..lineTo(7.75, 6.0)
      ..lineTo(13.3, 11.5)
      ..close();
    final fgRoofPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(fgRoof, fgRoofPaint);

    // Arched door on fg cottage
    final fgDoorPath = Path()
      ..moveTo(6.0, 20.5)
      ..lineTo(6.0, 15.0)
      ..arcToPoint(
        const Offset(9.5, 15.0),
        radius: const Radius.circular(1.75),
        clockwise: true,
      )
      ..lineTo(9.5, 20.5)
      ..close();
    final fgDoorPaint = Paint()
      ..color = darkTeal
      ..style = PaintingStyle.fill;
    canvas.drawPath(fgDoorPath, fgDoorPaint);

    // Attic round window
    final atticPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(7.75, 9.2), 1.0, atticPaint);
  }

  /// 20. War Memorial: Heroic memorial obelisk with eternal flame & star
  void _drawWarMemorial(Canvas canvas) {
    // Stepped base plinth
    final base2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.5, 18.5, 17.0, 2.2),
      const Radius.circular(0.8),
    );
    final basePaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawRRect(base2, basePaint);

    final base1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6.0, 16.5, 12.0, 2.0),
      const Radius.circular(0.6),
    );
    canvas.drawRRect(base1, basePaint);

    // Tapered Memorial Obelisk Pillar
    final pillarPath = Path()
      ..moveTo(9.5, 16.5)
      ..lineTo(10.5, 5.0)
      ..lineTo(12.0, 3.0)
      ..lineTo(13.5, 5.0)
      ..lineTo(14.5, 16.5)
      ..close();
    final pillarPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawPath(pillarPath, pillarPaint);

    // Obelisk central shadow line
    final ridgePaint = Paint()
      ..color = darkTeal.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final ridgePath = Path()
      ..moveTo(12.0, 3.0)
      ..lineTo(13.5, 5.0)
      ..lineTo(14.5, 16.5)
      ..lineTo(12.0, 16.5)
      ..close();
    canvas.drawPath(ridgePath, ridgePaint);

    // Commemorative Star on pillar
    _drawSparkle(canvas, const Offset(12.0, 10.5), 1.8, gold);

    // Eternal Flame at pedestal
    final flamePath = Path()
      ..moveTo(12.0, 13.8)
      ..quadraticBezierTo(13.0, 15.0, 12.0, 16.5)
      ..quadraticBezierTo(11.0, 15.0, 12.0, 13.8)
      ..close();
    final flamePaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(flamePath, flamePaint);
  }

  /// 21. Museum: Classical colonnade museum with pediment and pillars
  void _drawMuseum(Canvas canvas) {
    // Pediment triangle roof
    final pedimentPath = Path()
      ..moveTo(2.5, 8.5)
      ..lineTo(12.0, 4.0)
      ..lineTo(21.5, 8.5)
      ..close();
    final pedimentPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(pedimentPath, pedimentPaint);

    // Architrave beam
    final beamRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.5, 8.5, 17.0, 1.8),
      const Radius.circular(0.6),
    );
    canvas.drawRRect(beamRect, pedimentPaint);

    // 4 Classical Pillars
    final pillarPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    const pillarWidth = 1.6;
    const pillarHeight = 7.5;
    final xs = [5.0, 9.5, 13.0, 17.4];
    for (final x in xs) {
      canvas.drawRect(
        Rect.fromLTWH(x, 10.3, pillarWidth, pillarHeight),
        pillarPaint,
      );
    }

    // Base podium plinth
    final plinthRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.5, 17.8, 19.0, 2.7),
      const Radius.circular(0.8),
    );
    final plinthPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawRRect(plinthRect, plinthPaint);
  }

  /// 22. All / Compass: Voyager compass with dual-tone needle
  void _drawCompass(Canvas canvas) {
    // Outer compass ring
    final ringPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(const Offset(12.0, 12.0), 8.5, ringPaint);

    // 4 Cardinal ticks
    final tickPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(12.0, 2.5),
      const Offset(12.0, 4.5),
      tickPaint,
    );
    canvas.drawLine(
      const Offset(12.0, 19.5),
      const Offset(12.0, 21.5),
      tickPaint,
    );
    canvas.drawLine(
      const Offset(2.5, 12.0),
      const Offset(4.5, 12.0),
      tickPaint,
    );
    canvas.drawLine(
      const Offset(19.5, 12.0),
      const Offset(21.5, 12.0),
      tickPaint,
    );

    // North needle (orange)
    final northPath = Path()
      ..moveTo(12.0, 12.0)
      ..lineTo(10.0, 11.5)
      ..lineTo(12.0, 5.0)
      ..lineTo(14.0, 11.5)
      ..close();
    final northPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(northPath, northPaint);

    // South needle (mint)
    final southPath = Path()
      ..moveTo(12.0, 12.0)
      ..lineTo(10.0, 12.5)
      ..lineTo(12.0, 19.0)
      ..lineTo(14.0, 12.5)
      ..close();
    final southPaint = Paint()
      ..color = mint
      ..style = PaintingStyle.fill;
    canvas.drawPath(southPath, southPaint);

    // Center pivot dot
    final centerDotPaint = Paint()
      ..color = highlight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.0, 12.0), 1.2, centerDotPaint);
  }

  /// Helper to draw a geometric 4-point sparkle
  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final sparklePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();

    canvas.drawPath(path, sparklePaint);
  }

  /// Helper to draw a tiered pine tree
  void _drawPineTree(Canvas canvas, Offset base, double height, Color color) {
    final treePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final halfWidth = height * 0.45;
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx + halfWidth, base.dy)
      ..lineTo(base.dx - halfWidth, base.dy)
      ..close();

    canvas.drawPath(path, treePaint);
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isDark != isDark;
  }
}
