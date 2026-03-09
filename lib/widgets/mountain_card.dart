import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';

class MountainCard extends StatelessWidget {
  final Mountain mountain;
  const MountainCard({super.key, required this.mountain});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
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
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: mountain.colors,
                ),
              ),
              child: Center(child: Text(mountain.emoji, style: const TextStyle(fontSize: 40))),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mountain.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(children: [
                    DifficultyTag(text: mountain.difficulty),
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

  void _showDetail(BuildContext context) {
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
            Text(mountain.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(mountain.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text('${mountain.location} · ${mountain.height}m · ${mountain.distance}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            Text(mountain.description, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DifficultyTag(text: mountain.difficulty),
                const SizedBox(width: 10),
                Text(mountain.time, style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class DifficultyTag extends StatelessWidget {
  final String text;
  const DifficultyTag({super.key, required this.text});

  Color get color {
    if (text == '초급') return Colors.green;
    if (text == '중급') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
