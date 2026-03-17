import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/hiking_plan.dart';

class PlanCard extends StatelessWidget {
  final HikingPlan plan;
  final VoidCallback onDelete;
  final ValueChanged<PlanStatus>? onStatusChanged;
  const PlanCard({super.key, required this.plan, required this.onDelete, this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = plan.status == PlanStatus.confirmed;
    return Dismissible(
      key: ValueKey(plan.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isConfirmed ? AppTheme.primary.withAlpha(51) : Colors.orange.withAlpha(51),
            width: 1.5,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Text(plan.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.mountain, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 13, color: context.appTextSub),
                    const SizedBox(width: 4),
                    Text(plan.date, style: TextStyle(color: context.appTextSub, fontSize: 13)),
                  ]),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final newStatus = isConfirmed ? PlanStatus.pending : PlanStatus.confirmed;
                onStatusChanged?.call(newStatus);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isConfirmed ? AppTheme.primary.withAlpha(25) : Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isConfirmed ? '확정 ✓' : '조율 중',
                  style: TextStyle(
                    color: isConfirmed ? AppTheme.primary : Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
