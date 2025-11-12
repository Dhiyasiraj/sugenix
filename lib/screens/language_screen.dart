import 'package:flutter/material.dart';
import 'package:sugenix/services/language_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'en';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final code = await LanguageService.getSelectedLanguage();
    if (mounted) {
      setState(() {
        _selected = code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C4556),
      ),
      body: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: LanguageService.getSupportedLanguages().length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final lang = LanguageService.getSupportedLanguages()[index];
                final code = lang['code']!;
                final name = lang['name']!;
                final flag = lang['flag'] ?? '';
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Text(flag, style: const TextStyle(fontSize: 20)),
                  title: Text(name,
                      style: const TextStyle(
                          color: Color(0xFF0C4556), fontWeight: FontWeight.w600)),
                  trailing: Radio<String>(
                    value: code,
                    groupValue: _selected,
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() => _selected = v);
                      await LanguageService.setSelectedLanguage(v);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language updated')),
                      );
                    },
                  ),
                  onTap: () async {
                    setState(() => _selected = code);
                    await LanguageService.setSelectedLanguage(code);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language updated')),
                    );
                  },
                );
              },
            ),
      backgroundColor: const Color(0xFFF5F6F8),
    );
  }
}


