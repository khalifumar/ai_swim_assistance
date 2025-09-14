import 'package:flutter/material.dart';
import '../../widgets/aqua_background.dart';
import '../../widgets/glass_card.dart';

class TargetPage extends StatefulWidget {
  static const route = '/target';
  const TargetPage({super.key});

  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  DateTime? _deadline;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _deadline ?? now,
    );
    if (d != null) setState(() => _deadline = d);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please choose a deadline')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Target created: ${_nameCtrl.text} • ${_valueCtrl.text} • ${_deadline!.toIso8601String().split("T").first}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('Target'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: AquaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GlassCard(
                    title: 'Create Target',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Name target',
                            hintText: 'Masukan nama target…',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _valueCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Value target',
                            hintText: 'Misal: 7:00 (pace) / 10 (lap)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Deadline Target',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _deadline == null
                                      ? 'Pilih tanggal target…'
                                      : _deadline!.toIso8601String().split('T').first,
                                ),
                                const Spacer(),
                                const Icon(Icons.calendar_month_outlined),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _submit,
                                child: const Text('Create'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
