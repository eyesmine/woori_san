import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/hiking_record.dart';
import '../providers/mountain_provider.dart';
import '../widgets/elevation_chart.dart';
import '../widgets/route_map_widget.dart';
import '../services/share_service.dart';

class RecordDetailScreen extends StatelessWidget {
  final String recordId;
  const RecordDetailScreen({super.key, required this.recordId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final records = context.watch<MountainProvider>().records;
    final record = records.cast<HikingRecord?>().firstWhere((r) => r?.id == recordId, orElse: () => null);

    if (record == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.invalidAccess, style: TextStyle(color: context.appTextSub, fontSize: 16))));
    }

    final hasElevation = record.elevations.isNotEmpty && record.elevations.any((e) => e != 0.0);
    final hasRoute = record.routePoints != null && record.routePoints!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => ShareService.shareRecord(record),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(record.mountain, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)]),
                ),
                child: Center(child: Padding(padding: const EdgeInsets.only(bottom: 24), child: Text(record.emoji, style: const TextStyle(fontSize: 64)))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _InfoCard(icon: Icons.straighten, label: l.distance, value: record.distance)),
                  const SizedBox(width: 12),
                  Expanded(child: _InfoCard(icon: Icons.timer_outlined, label: l.duration, value: record.duration)),
                  const SizedBox(width: 12),
                  Expanded(child: _InfoCard(icon: Icons.trending_up, label: l.elevationGainLabel, value: record.elevationGain != null ? '${record.elevationGain}m' : '-')),
                ],
              ),
            ),
          ),
          if (hasElevation)
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: ElevationChart(elevations: record.elevations))),
          if (hasRoute)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.routeMap, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
                    const SizedBox(height: 12),
                    RouteMapWidget(routePoints: record.routePoints!.map((p) => Map<String, dynamic>.from(p)).toList()),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.calendar_today_outlined, label: l.selectDate, value: record.date),
                    if (record.startTime != null) ...[const Divider(height: 24), _DetailRow(icon: Icons.play_circle_outline, label: l.startPoint, value: DateFormat('HH:mm').format(record.startTime!))],
                    if (record.endTime != null) ...[const Divider(height: 24), _DetailRow(icon: Icons.stop_circle_outlined, label: l.endPoint, value: DateFormat('HH:mm').format(record.endTime!))],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: context.appSurface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: context.appText)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: context.appTextSub, fontSize: 11), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.primary, size: 20),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(color: context.appTextSub, fontSize: 14)),
      const Spacer(),
      Text(value, style: TextStyle(color: context.appText, fontWeight: FontWeight.w600, fontSize: 14)),
    ]);
  }
}
