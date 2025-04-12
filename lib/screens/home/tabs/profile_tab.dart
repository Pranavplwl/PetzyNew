// screens/home/tabs/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:petzy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (user?.photoURL != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user!.photoURL!),
            )
          else
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          const SizedBox(height: 20),
          Text(
            'Name: ${user?.displayName ?? 'Not provided'}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Email: ${user?.email ?? 'Not provided'}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Email Verified: ${user?.emailVerified ?? false ? 'Yes' : 'No'}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement profile editing
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
