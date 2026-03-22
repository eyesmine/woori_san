import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../models/hiking_plan.dart';
import '../providers/mountain_provider.dart';
import '../providers/plan_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/checklist_card.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.hikingPlan),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: () => _showNewPlanSheet(context),
          ),
        ],
      ),
      body: Consumer<PlanProvider>(
        builder: (context, state, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const WeatherCard(),
            const SizedBox(height: 24),

            Text(l.upcomingHikes, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
            const SizedBox(height: 12),

            if (state.plans.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(l.noPlanYet, textAlign: TextAlign.center, style: TextStyle(color: context.appTextSub, height: 1.5)),
                ),
              ),

            ...state.plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PlanCard(
                plan: plan,
                onDelete: () => state.removePlan(plan.id),
                onStatusChanged: (status) => state.updatePlanStatus(plan.id, status),
              ),
            )),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => _showNewPlanSheet(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary.withAlpha(77), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.primary.withAlpha(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(l.addPlan, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(l.checklist, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
            const SizedBox(height: 12),
            const ChecklistCard(),
          ],
        ),
      ),
    );
  }

  void _showNewPlanSheet(BuildContext context) {
    final mountains = context.read<MountainProvider>().mountains;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewPlanSheet(
        mountains: mountains,
        onSave: (plan) => context.read<PlanProvider>().addPlan(plan),
      ),
    );
  }
}

class _NewPlanSheet extends StatefulWidget {
  final List<Mountain> mountains;
  final Function(HikingPlan) onSave;
  const _NewPlanSheet({required this.mountains, required this.onSave});

  @override
  State<_NewPlanSheet> createState() => _NewPlanSheetState();
}

class _NewPlanSheetState extends State<_NewPlanSheet> {
  String? _selectedMountain;
  String? _selectedMountainId;
  String? _selectedEmoji;
  DateTime? _selectedDate;
  final _mountainSearchController = TextEditingController();
  final _mountainSearchFocus = FocusNode();
  String _mountainQuery = '';

  @override
  void dispose() {
    _mountainSearchController.dispose();
    _mountainSearchFocus.dispose();
    super.dispose();
  }

  List<Mountain> get _filteredMountains {
    if (_mountainQuery.isEmpty) return [];
    return widget.mountains
        .where((m) => m.name.contains(_mountainQuery) || m.location.contains(_mountainQuery))
        .take(10)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(l.newPlan, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.appText)),
            const SizedBox(height: 20),

            Text(l.whichMountain, style: TextStyle(fontWeight: FontWeight.w600, color: context.appTextSub, fontSize: 13)),
            const SizedBox(height: 8),

            // 선택된 산 표시
            if (_selectedMountain != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Row(
                  children: [
                    Text(_selectedEmoji ?? '🏔️', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_selectedMountain!, style: TextStyle(fontWeight: FontWeight.w700, color: context.appText, fontSize: 15))),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedMountain = null;
                        _selectedMountainId = null;
                        _selectedEmoji = null;
                        _mountainSearchController.clear();
                        _mountainQuery = '';
                      }),
                      child: Icon(Icons.close, size: 18, color: context.appTextSub),
                    ),
                  ],
                ),
              ),

            // 검색 입력
            if (_selectedMountain == null)
              TextField(
                controller: _mountainSearchController,
                focusNode: _mountainSearchFocus,
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
                  filled: true,
                  fillColor: context.appBg,
                ),
                style: TextStyle(fontSize: 14, color: context.appText),
                onChanged: (v) => setState(() => _mountainQuery = v.trim()),
              ),

            // 검색 결과
            if (_selectedMountain == null && _filteredMountains.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filteredMountains.map((m) => ChoiceChip(
                    label: Text('${m.emoji} ${m.name}'),
                    selected: false,
                    onSelected: (_) => setState(() {
                      _selectedMountain = m.name;
                      _selectedMountainId = m.id;
                      _selectedEmoji = m.emoji;
                      _mountainQuery = '';
                      _mountainSearchController.clear();
                    }),
                    backgroundColor: context.appSurface,
                    labelStyle: TextStyle(color: context.appText, fontSize: 13),
                  )).toList(),
                ),
              ),

            if (_selectedMountain == null && _mountainQuery.isNotEmpty && _filteredMountains.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(l.noSearchResults, style: TextStyle(color: context.appTextSub, fontSize: 13), textAlign: TextAlign.center),
              ),

            const SizedBox(height: 16),
            Text(l.whenToGo, style: TextStyle(fontWeight: FontWeight.w600, color: context.appTextSub, fontSize: 13)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate != null
                        ? DateFormat('M월 d일', 'ko_KR').format(_selectedDate!)
                        : l.selectDate,
                    style: TextStyle(color: _selectedDate != null ? context.appText : Colors.grey),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedMountain != null && _selectedDate != null)
                    ? () {
                        widget.onSave(HikingPlan(
                          mountain: _selectedMountain!,
                          mountainId: int.tryParse(_selectedMountainId ?? ''),
                          date: '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                          status: PlanStatus.pending,
                          emoji: _selectedEmoji ?? '🏔️',
                        ));
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(l.addPlanButton),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
