import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';
import '../theme/app_theme.dart';

class BadgeTile extends StatelessWidget {
  final HikingBadge badge;
  final bool isEarned;
  final bool isKorean;
  final String? progress;

  const BadgeTile({
    super.key,
    required this.badge,
    required this.isEarned,
    this.isKorean = true,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final title = isKorean ? badge.titleKo : badge.titleEn;
    final description = isKorean ? badge.descriptionKo : badge.descriptionEn;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? const Color(0xFFFFD700).withAlpha(128) : Colors.grey.withAlpha(51),
          width: isEarned ? 2 : 1,
        ),
        boxShadow: isEarned
            ? [BoxShadow(color: const Color(0xFFFFD700).withAlpha(38), blurRadius: 8, offset: const Offset(0, 2))]
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned ? const Color(0xFFFFD700).withAlpha(38) : Colors.grey.withAlpha(38),
                  ),
                  child: Center(
                    child: Text(isEarned ? badge.emoji : '🔒', style: TextStyle(fontSize: isEarned ? 24 : 20)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isEarned ? context.appText : context.appTextSub),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (!isEarned && progress != null)
                  Text(progress!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.primary.withAlpha(179)), textAlign: TextAlign.center)
                else
                  Text(
                    description,
                    style: TextStyle(fontSize: 10, color: isEarned ? context.appTextSub : Colors.grey.withAlpha(128)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isEarned)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                child: const Center(child: Icon(Icons.check, size: 10, color: Colors.white)),
              ),
            ),
          if (!isEarned)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withAlpha(77) : Colors.white.withAlpha(77),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
