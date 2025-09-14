import 'package:flutter/material.dart';
import '../../widgets/aqua_background.dart';
import '../../widgets/glass_card.dart';

class ProfilePage extends StatelessWidget {
  static const route = '/profile';
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AquaBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: GlassCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: const Color(0xFFEAF4FF),
                        child: Icon(Icons.person,
                            color: Colors.blue.shade900, size: 42),
                      ),
                      const SizedBox(height: 14),
                      const Text('Darlene Hegan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      const Text('Coach', style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      const Text('+62 812-3456-7890',
                          style: TextStyle(color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined)),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.phone_outlined)),
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
