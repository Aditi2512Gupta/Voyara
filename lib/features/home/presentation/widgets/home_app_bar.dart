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
            // Header Logo (matching mockup Header Logo)
            const VoyaraLogo.header(height: 38),

            // Balanced Action Cluster: Notification Bell & Profile Avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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

                const SizedBox(width: 14),

                // User Profile Avatar with distinctive teal border and berry background
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

        const SizedBox(height: 18),

        // 2. Greeting & Discover Tagline
        Text(
          greeting,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark
                ? AppColors.textPrimaryDark
                : const Color(0xFF0F2F33),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "Discover amazing destinations around the world",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
      ],
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
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626), // Coral/red matching mockup
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
      color: const Color(0xFFB81D58), // Distinctive berry/magenta from mockup
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
