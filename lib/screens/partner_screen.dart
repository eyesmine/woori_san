import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  final _partnerIdController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _partnerIdController.dispose();
    super.dispose();
  }

  Future<void> _registerPartner() async {
    final partnerId = _partnerIdController.text.trim();
    if (partnerId.isEmpty) return;

    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.registerPartner(partnerId);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l.partnerRegistered : (auth.error ?? ''))),
    );
    if (success) {
      _partnerIdController.clear();
    }
  }

  Future<void> _removePartner() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.removePartner),
        content: Text(l.removePartnerConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.removePartner, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.removePartner();

    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l.partnerRemoved : (auth.error ?? ''))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.partner),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final hasPartner = user?.partnerId != null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (hasPartner) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primary.withAlpha(30),
                        child: Text(
                          (user?.partnerNickname ?? user?.partnerId ?? '?').characters.first.toUpperCase(),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user?.partnerNickname != null)
                        Text(user!.partnerNickname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.appText)),
                      const SizedBox(height: 4),
                      Text(user?.partnerId ?? '', style: TextStyle(color: context.appTextSub, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _removePartner,
                    icon: _isProcessing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.person_remove, color: Colors.red),
                    label: Text(l.removePartner, style: const TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppTheme.primary.withAlpha(80)),
                      const SizedBox(height: 16),
                      Text(l.noPartnerYet, textAlign: TextAlign.center, style: TextStyle(color: context.appTextSub, fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _partnerIdController,
                  decoration: InputDecoration(
                    hintText: l.partnerSearchHint,
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _registerPartner,
                    child: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l.registerPartner),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
