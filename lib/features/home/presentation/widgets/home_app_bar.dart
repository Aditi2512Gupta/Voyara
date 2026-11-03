import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../shared/widgets/voyara_logo.dart';
import '../../../profile/providers/profile_provider.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final profileAsync = ref.watch(profileProvider);

    final displayName = profileAsync.maybeWhen(
      data: (user) => (user != null && user.name.trim().isNotEmpty)
          ? "${user.name.split(' ').first} 👋"
          : "Traveler! 👋",
      orElse: () => "Traveler! 👋",
    );

    final initial = profileAsync.maybeWhen(
      data: (user) => (user != null && user.name.trim().isNotEmpty)
          ? user.name.trim()[0].toUpperCase()
          : "T",
      orElse: () => "T",
    );

    final photoUrl = profileAsync.maybeWhen(
      data: (user) => user?.photoUrl ?? '',
      orElse: () => '',
    );

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? "Good Morning"
        : (hour < 17 ? "Good Afternoon" : "Good Evening");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Top Brand & Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Logo
            const VoyaraLogo.header(height: 38),

            // Balanced Action Cluster: My Trips Button, Notification Bell & Profile Avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // My Trips Button
                _buildMyTripsButton(context: context, isDark: isDark),

                const SizedBox(width: 10),

                // Notification Button with badge
                notificationsAsync.when(
                  loading: () => _buildNotificationBell(
                    context: context,
                    isDark: isDark,
                    unreadCount: 0,
                  ),
                  error: (error, stackTrace) => _buildNotificationBell(
                    context: context,
                    isDark: isDark,
                    unreadCount: 0,
                  ),
                  data: (notifications) {
                    final unreadCount = notifications
                        .where((notification) => !notification.read)
                        .length;
                    return _buildNotificationBell(
                      context: context,
                      isDark: isDark,
                      unreadCount: unreadCount,
                    );
                  },
                ),

                const SizedBox(width: 12),

                // User Profile Avatar
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(initial),
                            )
                          : _buildDefaultAvatar(initial),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Compact Scenic Greeting Banner
        _buildScenicGreetingBanner(
          context: context,
          isDark: isDark,
          greeting: greeting,
          displayName: displayName,
        ),
      ],
    );
  }

  Widget _buildScenicGreetingBanner({
    required BuildContext context,
    required bool isDark,
    required String greeting,
    required String displayName,
  }) {
    return Container(
      width: double.infinity,
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF142929) : const Color(0xFFE2F4F2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Tropical Limestone Island Scenery Image on the Right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 190,
              child: Image.asset(
                'assets/images/voyara_scenic_landscape.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),

            // Soft Gradient Overlay from Left to Right for High Text Legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF102828),
                            const Color(0xFF102828).withValues(alpha: 0.95),
                            const Color(0xFF102828).withValues(alpha: 0.40),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFE3F5F3),
                            const Color(0xFFE3F5F3).withValues(alpha: 0.95),
                            const Color(0xFFE3F5F3).withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.48, 0.75, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Left Side: Greeting & User Name Lockup
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: SizedBox(
                width: 195,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF4A6B6A),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : const Color(0xFF0F3133),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Discover amazing destinations around the world",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF4E6B6A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side: Rotated Postcard/Scrapbook Sticker
            Positioned(
              right: 14,
              top: 14,
              child: Transform.rotate(
                angle: 0.08, // ~4.5 degrees playful tilt matching mockup
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 6,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStickerText("Explore"),
                      _buildStickerText("Plan"),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStickerText("Travel"),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.flight_takeoff_rounded,
                            size: 10,
                            color: Color(0xFF2C4A4A),
                          ),
                        ],
                      ),
                      _buildStickerText("Repeat"),
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

  Widget _buildStickerText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Courier',
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: Color(0xFF234444),
        height: 1.25,
      ),
    );
  }

  Widget _buildMyTripsButton({
    required BuildContext context,
    required bool isDark,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Tooltip(
        message: 'My Trips',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => context.push('/saved-trips?title=My Trips'),
            child: Icon(
              Icons.luggage_outlined,
              size: 21,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell({
    required BuildContext context,
    required bool isDark,
    required int unreadCount,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => context.push('/notifications'),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 21,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: unreadCount > 9 ? 5 : 4,
                vertical: 2,
              ),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.backgroundDark : Colors.white,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String initial) {
    return Container(
      color: const Color(0xFFB81D58),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
