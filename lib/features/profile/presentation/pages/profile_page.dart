import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/edit-profile');
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: profile.when(
        data: (user) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/edit-profile');
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              const SizedBox(height: 8),

              Center(child: Text(user.email)),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  user.phone.isEmpty ? "No phone number" : user.phone,
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "Member since ${user.joinedOn.year}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.favorite, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              "Favorites",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.flight_takeoff, color: Colors.blue),
                            SizedBox(height: 8),
                            Text(
                              "Trips",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text("Favorites"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/favorites');
                },
              ),

              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text("My Trips"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/trips');
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/settings');
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
