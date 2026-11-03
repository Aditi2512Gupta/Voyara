import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/notification_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import 'voyara_logo.dart';

class VoyaraAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const VoyaraAppBar({
    super.key,
    this.showBackButton = true,
    this.onBackPressed,
    this.showActions = true,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showActions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final profileAsync = ref.watch(profileProvider);

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

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              // 1. Back button (if enabled)
              if (showBackButton)
                IconButton(
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF0F2F33),
                    size: 24,
                  ),
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),

              // 2. Header Logo
              const VoyaraLogo.header(height: 34),

              const Spacer(),

              // 3. Actions: Bell and Avatar
              if (showActions) ...[
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
                        .where((n) => !n.read)
                        .length;
                    return _buildNotificationBell(
                      context: context,
                      isDark: isDark,
                      unreadCount: unreadCount,
                    );
                  },
                ),

                const SizedBox(width: 14),

                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 38,
                    height: 38,
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
            ],
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
          width: 38,
          height: 38,
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
                size: 20,
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
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFDC2626,
                ), // Crisp coral/red matching mockup
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
                  fontSize: 9,
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
      color: const Color(
        0xFFB81D58,
      ), // Distinctive berry/magenta from reference
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
