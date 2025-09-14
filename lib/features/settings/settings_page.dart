import 'package:flutter/material.dart';
import '../../widgets/aqua_background.dart';
import '../../widgets/glass_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const Text('Setting',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const Spacer(),
                  const SizedBox(width: 48), // spacer kanan biar simetris
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Item('Privasi'),
                      _Item('Penyimpanan Data'),
                      _Item('Bahasa'),
                      _Item('Mode'),
                      _Item('Kebijakan Privasi'),
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

class _Item extends StatelessWidget {
  final String title;
  const _Item(this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      onTap: () {},
    );
  }
}
