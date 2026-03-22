import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class ElevationChart extends StatelessWidget {
  final List<double> elevations;
  final double height;

  const ElevationChart({
    super.key,
    required this.elevations,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (elevations.isEmpty) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final minElev = elevations.reduce(min);
    final maxElev = elevations.reduce(max);
    final range = maxElev - minElev;
    final safeYMin = range < 1 ? minElev - 10 : (minElev - range * 0.1).floorToDouble();
    final safeYMax = range < 1 ? maxElev + 10 : (maxElev + range * 0.1).ceilToDouble();

    final spots = <FlSpot>[];
    for (int i = 0; i < elevations.length; i++) {
      spots.add(FlSpot(i.toDouble(), elevations[i]));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.elevationProfile, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
          const SizedBox(height: 8),
          Row(
            children: [
              _ElevLabel(label: l.maxElevation, value: '${maxElev.toStringAsFixed(0)}m', color: AppTheme.primary),
              const SizedBox(width: 16),
              _ElevLabel(label: l.minElevation, value: '${minElev.toStringAsFixed(0)}m', color: AppTheme.accent),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                minY: safeYMin,
                maxY: safeYMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calcInterval(safeYMax - safeYMin),
                  getDrawingHorizontalLine: (value) => FlLine(color: context.appTextSub.withAlpha(40), strokeWidth: 0.8),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: _calcInterval(safeYMax - safeYMin),
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('${value.toInt()}m', style: TextStyle(color: context.appTextSub, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.primary,
                    getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem(
                      '${spot.y.toStringAsFixed(0)}m',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    )).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: AppTheme.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.primary.withAlpha(80), AppTheme.primary.withAlpha(10)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calcInterval(double range) {
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    if (range <= 300) return 50;
    if (range <= 600) return 100;
    return 200;
  }
}

class _ElevLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ElevLabel({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(color: context.appTextSub, fontSize: 12)),
        Text(value, style: TextStyle(color: context.appText, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
