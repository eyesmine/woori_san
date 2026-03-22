import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SosSettingsScreen extends StatefulWidget {
  const SosSettingsScreen({super.key});

  @override
  State<SosSettingsScreen> createState() => _SosSettingsScreenState();
}

class _SosSettingsScreenState extends State<SosSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController = TextEditingController(text: settings.emergencyName ?? '');
    _phoneController = TextEditingController(text: settings.emergencyPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    context.read<SettingsProvider>().setEmergencyContact(name, phone);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.save)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.emergencySettings),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (settings.emergencyName != null && settings.emergencyPhone != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.emergency_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(settings.emergencyName!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.appText)),
                            const SizedBox(height: 4),
                            Text(settings.emergencyPhone!, style: TextStyle(fontSize: 14, color: context.appTextSub)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(l.emergencyName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.appText)),
              const SizedBox(height: 8),
              TextField(controller: _nameController, decoration: InputDecoration(hintText: l.emergencyName, prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary))),
              const SizedBox(height: 20),
              Text(l.emergencyPhone, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.appText)),
              const SizedBox(height: 8),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: l.emergencyPhone, prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primary))),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(l.save))),
            ],
          );
        },
      ),
    );
  }
}
