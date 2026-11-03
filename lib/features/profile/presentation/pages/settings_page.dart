import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled =
        NotificationService.instance.areNotificationsEnabled;
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    try {
      final user = ref.read(currentUserProvider);

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (!mounted) return;

      if (data != null && data.containsKey('notificationsEnabled')) {
        final remoteSetting = data['notificationsEnabled'] as bool? ?? true;
        setState(() {
          _notificationsEnabled = remoteSetting;
        });
        await NotificationService.instance.setNotificationsEnabled(
          remoteSetting,
        );
      }
    } catch (e) {
      debugPrint("Error loading remote notification setting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ResponsiveContentWrapper(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Preferences Card Group
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });

                      await NotificationService.instance
                          .setNotificationsEnabled(value);

                      try {
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                                'notificationsEnabled': value,
                              }, SetOptions(merge: true));
                        }
                      } catch (e) {
                        debugPrint(
                          "Error updating remote notification setting: $e",
                        );
                      }
                    },
                    title: const Text("Notifications"),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.scaffoldDark
                            : AppColors.warmCreamLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _divider(isDark),
                  SwitchListTile(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).setDarkMode(value);
                    },
                    title: const Text("Dark Mode"),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.scaffoldDark
                            : AppColors.warmCreamLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.dark_mode_outlined,
                        size: 20,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Information & Support Card Group
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.scaffoldDark
                            : AppColors.warmCreamLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text("Language"),
                    subtitle: const Text("English (Default)"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.language),
                              SizedBox(width: 8),
                              Text("Language"),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                                title: const Text("English"),
                                subtitle: const Text("Default language"),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "English is currently the supported language. More languages will be available in future updates.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _divider(isDark),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.scaffoldDark
                            : AppColors.warmCreamLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text("Privacy Policy"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.lock_outline),
                              SizedBox(width: 8),
                              Text("Privacy Policy"),
                            ],
                          ),
                          content: const SingleChildScrollView(
                            child: Text(
                              "Voyara values your privacy.\n\n"
                              "1. Information Collection: We store your account details, saved destinations, and travel plans to personalize your trip recommendations.\n\n"
                              "2. Location Data: Location access is used to show nearby destinations, hotels, and attractions.\n\n"
                              "3. Data Security: Your profile and booking records are stored securely with Firebase Authentication and Firestore.\n\n"
                              "4. Account Control: You can update your profile or delete your data anytime from Settings.",
                              style: TextStyle(height: 1.4, fontSize: 14),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _divider(isDark),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.scaffoldDark
                            : AppColors.warmCreamLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text("About"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(width: 8),
                              Text("About Voyara"),
                            ],
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Voyara",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Version 1.0.0",
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Your personal travel discovery companion. Explore destinations, discover nearby attractions, plan smart itineraries with AI, and track your journeys.",
                                style: TextStyle(height: 1.4, fontSize: 14),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout Action Tile
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    try {
                      await ref.read(authRepositoryProvider).signOut();

                      // Clear profile-related state so it cannot remain cached
                      ref.invalidate(profileProvider);

                      if (context.mounted) {
                        context.go('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Failed to logout: ${e.toString().replaceFirst(RegExp(r'^Exception: '), '')}",
                            ),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      indent: 56,
    );
  }
}
