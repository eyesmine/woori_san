import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/plan_provider.dart';

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, state, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: state.checklist.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return InkWell(
              onTap: () => state.toggleChecklistItem(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: item.checked ? AppTheme.primary : Colors.transparent,
                        border: Border.all(color: item.checked ? AppTheme.primary : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: item.checked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.text,
                      style: TextStyle(
                        color: item.checked ? context.appTextSub : context.appText,
                        decoration: item.checked ? TextDecoration.lineThrough : null,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
