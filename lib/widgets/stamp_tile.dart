import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/stamp.dart';
import '../providers/stamp_provider.dart';

class StampTile extends StatelessWidget {
  final Stamp mountain;
  final int globalIndex;
  const StampTile({super.key, required this.mountain, required this.globalIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: mountain.isStamped ? AppTheme.surface : Colors.grey.shade100,
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
                      color: mountain.isStamped ? AppTheme.textPrimary : Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mountain.height}m',
                    style: TextStyle(fontSize: 11, color: mountain.isStamped ? AppTheme.textSecondary : Colors.grey.shade300),
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
    );
  }

  void _showDetail(BuildContext context) {
    final state = context.read<StampProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('🏔️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(mountain.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text('${mountain.region} · ${mountain.height}m', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            if (mountain.isTogetherStamped)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.accent.withAlpha(25), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💑 함께 오른 날: ', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
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
                    const Text('✅ 완등한 날: ', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    Text(mountain.stampDate ?? '', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                child: const Text('아직 오르지 않은 산이에요 🌱\n함께 도전해 볼까요?', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
              ),
            const SizedBox(height: 16),
            if (!mountain.isStamped)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        state.toggleStamp(globalIndex);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('혼자 도장'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        state.toggleStamp(globalIndex, together: true);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('💑 함께 도장'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    state.toggleStamp(globalIndex);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('도장 취소'),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
