import 'package:flutter/material.dart';
import '../../widgets/aqua_background.dart';
import '../../widgets/glass_card.dart';
import '../profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AquaBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  Text(
                    'Welcome Coach!',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    // Profile mini card
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFEAF4FF),
                          child: Icon(Icons.person,
                              color: Colors.blue.shade900, size: 26),
                        ),
                        title: const Text('Darlene Hegan,'),
                        subtitle: const Text('Coach'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, ProfilePage.route),
                      ),
                    ),

                    // Dashboard section
                    GlassCard(
                      title: 'Dashboard',
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              _StatPill(label: 'Pace', value: '5:50'),
                              SizedBox(width: 8),
                              _StatPill(label: 'Lap', value: '7'),
                              SizedBox(width: 8),
                              _StatPill(label: 'Stroke', value: 'Freestyle'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  // Buka Dashboard (named route)
                                  onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text('Open Dashboard'),
                                      Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Target section
                    const GlassCard(
                      title: 'Target',
                      child: _TargetSection(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF9CCBFF), width: 1.7),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetSection extends StatelessWidget {
  const _TargetSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TargetRow(label: 'Pace :', value: '7:00'),
        const SizedBox(height: 8),
        const _TargetRow(label: 'Lap  :', value: '10'),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                // Buka Target (named route)
                onPressed: () => Navigator.of(context).pushNamed('/target'),
                child: const Text('Create Target'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label, value;
  const _TargetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9CCBFF), width: 1.7),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF9CCBFF), width: 1.4),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.check, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
