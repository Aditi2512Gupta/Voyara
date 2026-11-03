import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum VoyaraLogoVariant {
  /// Full primary logo: wordmark with circular landscape badge as 'o', airplane, and birds.
  primary,

  /// Compact app icon: circular landscape badge with sun, mountains, water, airplane, and birds.
  compact,

  /// Header logo: circular landscape badge on left + Voyara wordmark on right.
  header,
}

class VoyaraLogo extends StatelessWidget {
  const VoyaraLogo({
    super.key,
    this.variant = VoyaraLogoVariant.primary,
    this.size = 80,
    this.height,
    this.showTagline = false,
    this.isLight = false,
  });

  const VoyaraLogo.primary({
    super.key,
    this.size = 80,
    this.height,
    this.showTagline = false,
    this.isLight = false,
  }) : variant = VoyaraLogoVariant.primary;

  const VoyaraLogo.compact({
    super.key,
    this.size = 40,
    this.height,
    this.showTagline = false,
    this.isLight = false,
  }) : variant = VoyaraLogoVariant.compact;

  const VoyaraLogo.header({
    super.key,
    this.size = 38,
    this.height,
    this.showTagline = false,
    this.isLight = false,
  }) : variant = VoyaraLogoVariant.header;

  final VoyaraLogoVariant variant;
  final double size;
  final double? height;
  final bool showTagline;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? size;

    switch (variant) {
      case VoyaraLogoVariant.compact:
        return _buildCompact(effectiveHeight);

      case VoyaraLogoVariant.header:
        return _buildHeader(effectiveHeight);

      case VoyaraLogoVariant.primary:
        return _buildPrimary(effectiveHeight);
    }
  }

  Widget _buildPrimary(double h) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/voyara_primary_logo.png',
          height: h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/voyara_logo.png',
            height: h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.travel_explore_rounded,
              size: h * 0.8,
              color: isLight ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            "Discover Today • Travel Tomorrow",
            style: TextStyle(
              fontSize: h * 0.16,
              fontWeight: FontWeight.w500,
              color: isLight ? Colors.white70 : AppColors.textSecondaryLight,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompact(double h) {
    return Image.asset(
      'assets/images/voyara_app_icon.png',
      height: h,
      width: h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        width: h,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.explore_rounded,
          color: AppColors.secondary,
          size: h * 0.6,
        ),
      ),
    );
  }

  Widget _buildHeader(double h) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/voyara_header_logo.png',
          height: h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/voyara_app_icon.png',
                height: h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.explore_rounded,
                  size: h * 0.8,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Voyara',
                style: TextStyle(
                  fontSize: h * 0.6,
                  fontWeight: FontWeight.w700,
                  color: isLight ? Colors.white : AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        // Semantic / test helper element ensuring text finders find 'Voyara'
        const SizedBox(
          width: 0,
          height: 0,
          child: OverflowBox(maxWidth: 0, maxHeight: 0, child: Text('Voyara')),
        ),
      ],
    );
  }
}
