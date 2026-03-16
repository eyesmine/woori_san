import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';

class MountainCard extends StatelessWidget {
  final Mountain mountain;
  const MountainCard({super.key, required this.mountain});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/mountain/${mountain.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: mountain.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: mountain.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _gradientPlaceholder(),
                        errorWidget: (_, _, _) => _gradientPlaceholder(),
                      )
                    : _gradientPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mountain.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(children: [
                    DifficultyTag(difficulty: mountain.difficulty),
                    const SizedBox(width: 6),
                    Text(mountain.time, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: mountain.colors,
        ),
      ),
      child: Center(child: Text(mountain.emoji, style: const TextStyle(fontSize: 40))),
    );
  }
}

class DifficultyTag extends StatelessWidget {
  final Difficulty difficulty;
  const DifficultyTag({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: difficulty.color.withAlpha(25), borderRadius: BorderRadius.circular(6)),
      child: Text(difficulty.label, style: TextStyle(color: difficulty.color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
