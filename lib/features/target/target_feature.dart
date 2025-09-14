import 'package:flutter/material.dart';

class TargetFeature extends StatefulWidget {
  const TargetFeature({super.key});

  @override
  State<TargetFeature> createState() => _TargetFeatureState();
}

class _TargetFeatureState extends State<TargetFeature> {
  final _formKey = GlobalKey<FormState>();
  final _distanceCtrl = TextEditingController(text: '300');   // m
  final _timeCtrl = TextEditingController(text: '50:00');     // mm:ss
  final _paceCtrl = TextEditingController(text: '2:50');      // mm:ss per 100m

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _timeCtrl.dispose();
    _paceCtrl.dispose();
    super.dispose();
  }

  Duration? _parseClock(String s) {
    final p = s.split(':');
    if (p.length < 2 || p.length > 3) return null;
    if (p.any((x) => int.tryParse(x) == null)) return null;
    if (p.length == 2) {
      return Duration(minutes: int.parse(p[0]), seconds: int.parse(p[1]));
    } else {
      return Duration(
        hours: int.parse(p[0]),
        minutes: int.parse(p[1]),
        seconds: int.parse(p[2]),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final dist = double.parse(_distanceCtrl.text);
    final time = _parseClock(_timeCtrl.text)!;
    final pace = _parseClock(_paceCtrl.text)!;
    final avgSpeed = dist / time.inSeconds.clamp(1, 1 << 30);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved • ${dist.toStringAsFixed(0)} m • '
          '${time.inMinutes}:${(time.inSeconds % 60).toString().padLeft(2, '0')} • '
          '${pace.inMinutes}:${(pace.inSeconds % 60).toString().padLeft(2, '0')}/100m • '
          'Avg ${avgSpeed.toStringAsFixed(2)} m/s',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Target Renang')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Target',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _distanceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Distance (m)',
                        prefixIcon: Icon(Icons.social_distance),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) {
                          return 'Masukkan jarak yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _timeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Total Time (mm:ss atau hh:mm:ss)',
                        prefixIcon: Icon(Icons.timer),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          _parseClock(v ?? '') == null ? 'Format waktu salah' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _paceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Pace (mm:ss per 100m)',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          _parseClock(v ?? '') == null ? 'Format pace salah' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save'),
                            onPressed: _save,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.dashboard_outlined),
                            label: const Text('Open Dashboard (CSV Live)'),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/dashboard'),
                          ),
                        ),
                      ],
                    )
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
