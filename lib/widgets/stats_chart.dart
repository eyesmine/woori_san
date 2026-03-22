import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MonthlyHikesChart extends StatelessWidget {
  final Map<int, int> data;
  const MonthlyHikesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final gridColor = isDark ? Colors.white12 : Colors.black12;
    final maxY = data.values.fold<int>(0, max);
    final topY = maxY < 1 ? 1.0 : (maxY + 1).toDouble();

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: topY, minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) {
                return BarTooltipItem('${group.x + 1}월: ${rod.toY.toInt()}회', const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13));
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => SideTitleWidget(meta: meta, child: Text('${value.toInt() + 1}', style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500))))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: topY > 5 ? (topY / 5).ceilToDouble() : 1, getTitlesWidget: (value, meta) {
              if (value == meta.max || value == meta.min) return const SizedBox.shrink();
              return SideTitleWidget(meta: meta, child: Text(value.toInt().toString(), style: TextStyle(color: textColor, fontSize: 11)));
            })),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: topY > 5 ? (topY / 5).ceilToDouble() : 1, getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(12, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: (data[i + 1] ?? 0).toDouble(), color: AppTheme.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(show: true, toY: topY, color: isDark ? Colors.white.withAlpha(8) : AppTheme.primary.withAlpha(15))),
            ]);
          }),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class CumulativeDistanceChart extends StatelessWidget {
  final Map<int, double> data;
  const CumulativeDistanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final gridColor = isDark ? Colors.white12 : Colors.black12;

    final spots = <FlSpot>[];
    double cumulative = 0;
    for (int m = 1; m <= 12; m++) {
      cumulative += data[m] ?? 0;
      spots.add(FlSpot((m - 1).toDouble(), double.parse(cumulative.toStringAsFixed(1))));
    }
    final maxY = cumulative < 1 ? 10.0 : (cumulative * 1.2).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.6,
      child: LineChart(
        LineChartData(
          minX: 0, maxX: 11, minY: 0, maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem('${spot.x.toInt() + 1}월: ${spot.y.toStringAsFixed(1)}km', const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 1, getTitlesWidget: (value, meta) {
              final month = value.toInt() + 1;
              if (month % 2 == 0) return const SizedBox.shrink();
              return SideTitleWidget(meta: meta, child: Text('$month', style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500)));
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: maxY > 50 ? (maxY / 5).ceilToDouble() : (maxY > 10 ? (maxY / 5).ceilToDouble() : 2), getTitlesWidget: (value, meta) {
              if (value == meta.max || value == meta.min) return const SizedBox.shrink();
              return SideTitleWidget(meta: meta, child: Text(value.toStringAsFixed(0), style: TextStyle(color: textColor, fontSize: 11)));
            })),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY > 50 ? (maxY / 5).ceilToDouble() : (maxY > 10 ? (maxY / 5).ceilToDouble() : 2), getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots, isCurved: true, curveSmoothness: 0.3, color: AppTheme.primary, barWidth: 3, isStrokeCapRound: true,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: AppTheme.primary, strokeWidth: 1.5, strokeColor: Colors.white)),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primary.withAlpha(80), AppTheme.primary.withAlpha(10)])),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
