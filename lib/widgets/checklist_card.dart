import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/plan_provider.dart';

class ChecklistCard extends StatefulWidget {
  const ChecklistCard({super.key});

  @override
  State<ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<ChecklistCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<PlanProvider>().addChecklistItem(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<PlanProvider>(
      builder: (context, state, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            ...state.checklist.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Dismissible(
                key: ValueKey('${item.text}_$index'),
                direction: DismissDirection.startToEnd,
                onDismissed: (_) => context.read<PlanProvider>().removeChecklistItem(index),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: InkWell(
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
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l.checklistItemHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.appBg,
                    ),
                    style: TextStyle(fontSize: 14, color: context.appText),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primary,
                  tooltip: l.addChecklistItem,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
