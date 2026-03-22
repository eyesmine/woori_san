import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mountain_provider.dart';
import '../providers/stamp_provider.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showPhotoOptions(context),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppTheme.primary.withAlpha(30),
                            backgroundImage: _profileImage(user?.profileImageUrl),
                            child: user?.profileImageUrl == null
                                ? const Icon(Icons.person, size: 44, color: AppTheme.primary)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.nickname ?? '사용자',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.appText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: context.appTextSub, fontSize: 14),
                    ),
                    if (user?.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l.joinDate}: ${user!.createdAt!.year}.${user.createdAt!.month.toString().padLeft(2, '0')}.${user.createdAt!.day.toString().padLeft(2, '0')}',
                        style: TextStyle(color: context.appTextSub, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Consumer2<MountainProvider, StampProvider>(
                builder: (context, mState, sState, _) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(value: '${mState.totalHikes}', label: l.totalHikes),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _StatColumn(value: mState.totalDistance, label: l.totalDistance),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _StatColumn(value: '${sState.totalStamped}', label: l.tabStamp),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings section
              Text(l.settings, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.person_outline,
                title: l.editProfile,
                onTap: () => _showEditProfile(context),
              ),
              _SettingsTile(
                icon: Icons.bar_chart,
                title: l.statistics,
                onTap: () => context.push('/statistics'),
              ),
              _SettingsTile(
                icon: Icons.emoji_events_outlined,
                title: l.badges,
                onTap: () => context.push('/badges'),
              ),
              _SettingsTile(
                icon: Icons.favorite_outline,
                title: l.favorites,
                onTap: () => context.push('/favorites'),
              ),
              _SettingsTile(
                icon: Icons.people_outline,
                title: l.partner,
                onTap: () => context.push('/partner'),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) => _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: l.notifications,
                  trailing: Switch(
                    value: settings.notificationsEnabled,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (v) => settings.setNotificationsEnabled(v),
                  ),
                ),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) => _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: l.darkMode,
                  trailing: Switch(
                    value: settings.isDark,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (_) => settings.toggleDarkMode(),
                  ),
                ),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) => _SettingsTile(
                  icon: Icons.language,
                  title: l.language,
                  trailing: GestureDetector(
                    onTap: () => settings.toggleLocale(),
                    child: Text(
                      settings.locale.languageCode == 'ko' ? '한국어' : 'English',
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.download_for_offline_outlined,
                title: l.offlineMaps,
                onTap: () => context.push('/offline-maps'),
              ),
              _SettingsTile(
                icon: Icons.emergency_outlined,
                title: l.emergencyContact,
                onTap: () => context.push('/sos-settings'),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: l.appInfo,
                trailing: Text('v1.0.0', style: TextStyle(color: context.appTextSub)),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(l.logout, style: const TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  ImageProvider? _profileImage(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return NetworkImage(url);
    if (kIsWeb) return NetworkImage(url);
    return FileImage(File(url));
  }

  void _showPhotoOptions(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: Text(l.photoFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: Text(l.photoFromCamera),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  static const _maxImageBytes = 10 * 1024 * 1024; // 10MB

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source, maxWidth: 512, imageQuality: 85);
      if (xFile == null) return;

      // 10MB 제한 체크
      final fileSize = await xFile.length();
      if (fileSize > _maxImageBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.imageTooLarge ?? 'Image must be under 10MB')),
          );
        }
        return;
      }

      // 서버에 업로드 후 URL을 받아야 하지만, 현재는 로컬 경로를 임시 저장
      if (context.mounted) {
        context.read<AuthProvider>().updateProfile(profileImageUrl: xFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.imagePickError ?? 'Cannot select image')),
        );
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.logout),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: Text(l.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.user?.nickname ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(l.editProfile, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.appText)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: l.nickname),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  auth.updateProfile(nickname: controller.text.trim());
                  Navigator.pop(context);
                },
                child: Text(l.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.title, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: context.appTextSub),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
