import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';

class StampScreen extends StatelessWidget {
  const StampScreen({super.key});

  int get _totalStamped => stampMountains.where((m) => m.isStamped).length;
  int get _togetherStamped => stampMountains.where((m) => m.isTogetherStamped).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('도장 컬렉션')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 진행 현황 헤더
          _ProgressHeader(total: stampMountains.length, stamped: _totalStamped, together: _togetherStamped),
          const SizedBox(height: 24),

          // 함께 찍은 도장 강조
          if (_togetherStamped > 0) ...[
            Row(children: [
              const Text('💑 함께 오른 산', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('$_togetherStamped개', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
              itemCount: stampMountains.where((m) => m.isTogetherStamped).length,
              itemBuilder: (context, index) {
                final mountains = stampMountains.where((m) => m.isTogetherStamped).toList();
                return _StampTile(mountain: mountains[index]);
              },
            ),
            const SizedBox(height: 28),
          ],

          // 전체 도장 목록
          Row(children: [
            const Text('전체 명산', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(width: 8),
            Text('$_totalStamped / ${stampMountains.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
            itemCount: stampMountains.length,
            itemBuilder: (context, index) => _StampTile(mountain: stampMountains[index]),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int total;
  final int stamped;
  final int together;

  const _ProgressHeader({required this.total, required this.stamped, required this.together});

  @override
  Widget build(BuildContext context) {
    final progress = stamped / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('명산 100 도전', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '$stamped', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                        TextSpan(text: ' / $total', style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              // 원형 진행률
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                    Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 같이 찍은 도장 표시
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💑', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('함께 $together개 오름', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 14)),
                    Text('${total - stamped}개의 산이 여러분을 기다리고 있어요', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StampTile extends StatelessWidget {
  final StampMountain mountain;
  const _StampTile({required this.mountain});

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
                ? AppTheme.accent.withOpacity(0.5)
                : mountain.isStamped
                    ? AppTheme.primary.withOpacity(0.2)
                    : Colors.grey.shade200,
            width: mountain.isTogetherStamped ? 2 : 1,
          ),
          boxShadow: mountain.isStamped
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 도장 이미지 영역
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mountain.isStamped
                          ? (mountain.isTogetherStamped ? AppTheme.accent.withOpacity(0.15) : AppTheme.primary.withOpacity(0.1))
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
            // 함께 도장 뱃지
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
            // 미완성 표시
            if (!mountain.isStamped)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('🏔️', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(mountain.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text('${mountain.region} · ${mountain.height}m', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            if (mountain.isTogetherStamped)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
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
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}