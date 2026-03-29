import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/stamp.dart';
import '../providers/mountain_provider.dart';

class StampTile extends StatelessWidget {
  final Stamp mountain;
  final int globalIndex;
  const StampTile({super.key, required this.mountain, required this.globalIndex});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statusLabel = mountain.isStamped
        ? (l?.stampedStatus ?? 'Stamped')
        : (l?.unstampedStatus ?? 'Not stamped');
    return Semantics(
      label: '${mountain.name}, ${mountain.height}m, $statusLabel',
      button: true,
      child: GestureDetector(
        onTap: () => _showDetail(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: mountain.isStamped ? context.appSurface : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mountain.isTogetherStamped
                ? AppTheme.accent.withAlpha(128)
                : mountain.isStamped
                    ? AppTheme.primary.withAlpha(51)
                    : Colors.grey.shade200,
            width: mountain.isTogetherStamped ? 2 : 1,
          ),
          boxShadow: mountain.isStamped
              ? [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mountain.isStamped
                          ? (mountain.isTogetherStamped ? AppTheme.accent.withAlpha(38) : AppTheme.primary.withAlpha(25))
                          : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        mountain.isStamped ? '🏔️' : '⬜',
                        style: TextStyle(fontSize: mountain.isStamped ? 24 : 20, color: mountain.isStamped ? null : Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mountain.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mountain.isStamped ? context.appText : Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mountain.height}m',
                    style: TextStyle(fontSize: 11, color: mountain.isStamped ? context.appTextSub : Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            if (mountain.isTogetherStamped)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                  child: const Center(child: Text('💑', style: TextStyle(fontSize: 9))),
                ),
              ),
            if (!mountain.isStamped)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(128),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // 산 ID 찾기 (MountainProvider에서 이름으로 매칭)
    final mountainData = context.read<MountainProvider>().mountains
        .where((m) => m.name == mountain.name)
        .toList();
    final mountainId = mountainData.isNotEmpty ? mountainData.first.id : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('🏔️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(mountain.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.appText)),
              Text('${mountain.region} · ${mountain.height}m', style: TextStyle(color: context.appTextSub, fontSize: 14)),
              const SizedBox(height: 16),
              if (mountain.isTogetherStamped)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.accent.withAlpha(25), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💑 ${l.togetherClimbedDate}: ', style: TextStyle(fontWeight: FontWeight.w600, color: context.appText)),
                      Text(mountain.stampDate ?? '', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              else if (mountain.isStamped)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✅ ${l.climbedDate}: ', style: TextStyle(fontWeight: FontWeight.w600, color: context.appText)),
                      Text(mountain.stampDate ?? '', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                  child: Text(l.notClimbedYet, textAlign: TextAlign.center, style: TextStyle(color: context.appTextSub, height: 1.5)),
                ),
              const SizedBox(height: 16),
              if (!mountain.isStamped && mountainId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/tracking?mountainId=$mountainId');
                    },
                    icon: const Icon(Icons.directions_walk),
                    label: Text(l.startHiking),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
