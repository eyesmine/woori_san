import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final List<_Plan> _plans = [
    _Plan(mountain: '북한산', date: '3월 15일 (토)', status: PlanStatus.confirmed, emoji: '⛰️'),
    _Plan(mountain: '관악산', date: '3월 29일 (토)', status: PlanStatus.pending, emoji: '🌄'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('등산 계획'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: _showNewPlanSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 날씨 미리보기 카드
          _WeatherCard(),
          const SizedBox(height: 24),

          // 예정된 산행
          const Text('예정된 산행', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),

          ..._plans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanCard(plan: plan),
          )),

          const SizedBox(height: 24),

          // 새 계획 추가 버튼
          GestureDetector(
            onTap: _showNewPlanSheet,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.primary.withOpacity(0.03),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('새 산행 계획 추가', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 준비물 체크리스트
          const Text('준비물 체크리스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          _ChecklistCard(),
        ],
      ),
    );
  }

  void _showNewPlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewPlanSheet(
        onSave: (plan) {
          setState(() => _plans.add(plan));
        },
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74B3CE), Color(0xFF4895D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4895D0).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: const Row(
        children: [
          Text('☀️', style: TextStyle(fontSize: 48)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이번 주 토요일', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('등산하기 딱 좋은 날씨!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('맑음 · 12°C · 바람 약함', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PlanStatus { confirmed, pending }

class _Plan {
  final String mountain;
  final String date;
  final PlanStatus status;
  final String emoji;

  _Plan({required this.mountain, required this.date, required this.status, required this.emoji});
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = plan.status == PlanStatus.confirmed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConfirmed ? AppTheme.primary.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(plan.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.mountain, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(plan.date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isConfirmed ? AppTheme.primary.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatefulWidget {
  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  final List<Map<String, dynamic>> _items = [
    {'text': '등산화', 'checked': true},
    {'text': '물 (500ml × 2)', 'checked': true},
    {'text': '간식 (에너지바, 견과류)', 'checked': false},
    {'text': '방풍자켓', 'checked': false},
    {'text': '스틱', 'checked': false},
    {'text': '구급약', 'checked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return InkWell(
            onTap: () => setState(() => _items[index]['checked'] = !item['checked']),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: item['checked'] ? AppTheme.primary : Colors.transparent,
                      border: Border.all(color: item['checked'] ? AppTheme.primary : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: item['checked'] ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item['text'],
                    style: TextStyle(
                      color: item['checked'] ? AppTheme.textSecondary : AppTheme.textPrimary,
                      decoration: item['checked'] ? TextDecoration.lineThrough : null,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NewPlanSheet extends StatefulWidget {
  final Function(_Plan) onSave;
  const _NewPlanSheet({required this.onSave});

  @override
  State<_NewPlanSheet> createState() => _NewPlanSheetState();
}

class _NewPlanSheetState extends State<_NewPlanSheet> {
  String? _selectedMountain;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('새 산행 계획', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            const Text('어느 산으로?', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sampleMountains.map((m) => ChoiceChip(
                label: Text(m.name),
                selected: _selectedMountain == m.name,
                onSelected: (v) => setState(() => _selectedMountain = v ? m.name : null),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(color: _selectedMountain == m.name ? Colors.white : AppTheme.textPrimary),
              )).toList(),
            ),

            const SizedBox(height: 16),
            const Text('언제 갈까요?', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary, fontSize: 13)),
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
                        ? '${_selectedDate!.month}월 ${_selectedDate!.day}일'
                        : '날짜 선택',
                    style: TextStyle(color: _selectedDate != null ? AppTheme.textPrimary : Colors.grey),
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
                        widget.onSave(_Plan(
                          mountain: _selectedMountain!,
                          date: '${_selectedDate!.month}월 ${_selectedDate!.day}일',
                          status: PlanStatus.pending,
                          emoji: '🏔️',
                        ));
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('계획 추가하기'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}