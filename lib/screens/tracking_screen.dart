import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/tracking_provider.dart';
import '../providers/mountain_provider.dart';
import '../providers/stamp_provider.dart';
import '../models/mountain.dart';

class TrackingScreen extends StatefulWidget {
  final String? mountainId;
  const TrackingScreen({super.key, this.mountainId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final TrackingProvider _tracking;

  @override
  void initState() {
    super.initState();
    _tracking = context.read<TrackingProvider>();
    _tracking.addListener(_onTrackingChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tracking.isActive) {
        Mountain? mountain;
        if (widget.mountainId != null) {
          mountain = context.read<MountainProvider>().getMountainById(widget.mountainId!);
        }
        _tracking.start(mountain);
      }
    });
  }

  @override
  void dispose() {
    _tracking.removeListener(_onTrackingChanged);
    super.dispose();
  }

  void _onTrackingChanged() {
    if (_tracking.summitReached && !_tracking.summitDialogShown && mounted) {
      _tracking.markSummitDialogShown();
      // Auto-stamp
      final mountain = _tracking.currentMountain;
      if (mountain != null) {
        final stampProvider = context.read<StampProvider>();
        final stamps = stampProvider.stamps;
        final idx = stamps.indexWhere((s) => s.name == mountain.name);
        if (idx != -1 && !stamps[idx].isStamped) {
          stampProvider.toggleStamp(idx, together: true);
        }
      }
      _showSummitDialog();
    }
  }

  void _showSummitDialog() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(l.summitReached, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.appText)),
            const SizedBox(height: 8),
            Text(
              '${context.read<TrackingProvider>().currentMountain?.name ?? ""} 정상에 도착했습니다!\n${l.stampAwarded}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appTextSub, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.confirm, style: const TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _stopTracking() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.stopHiking),
        content: const Text('등산을 종료하고 기록을 저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.resumeHiking),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final record = context.read<TrackingProvider>().stop();
              context.read<MountainProvider>().addRecord(record);
              context.pop();
            },
            child: Text('${l.stopHiking} & ${l.save}', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<TrackingProvider>(
      builder: (context, tracking, _) {
        if (tracking.error != null) {
          return Scaffold(
            appBar: AppBar(title: Text(l.trackingTitle)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 48, color: context.appTextSub),
                  const SizedBox(height: 16),
                  Text(tracking.error!, style: TextStyle(fontSize: 16, color: context.appText)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('돌아가기'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(tracking.currentMountain?.name ?? '자유 등산'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (tracking.isActive) {
                  _stopTracking();
                } else {
                  context.pop();
                }
              },
            ),
          ),
          body: Column(
            children: [
              // Map area — NaverMap (native) / gradient placeholder (web)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: kIsWeb
                      ? _GradientPlaceholder(tracking: tracking)
                      : _TrackingMap(tracking: tracking),
                ),
              ),

              // Stats
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Timer
                      Text(
                        tracking.elapsedFormatted,
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: context.appText),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _TrackingStat(
                            label: l.currentDistance,
                            value: '${tracking.totalDistanceKm.toStringAsFixed(1)}km',
                            icon: Icons.straighten,
                          ),
                          _TrackingStat(
                            label: l.currentSpeed,
                            value: '${tracking.speedKmh}km/h',
                            icon: Icons.speed,
                          ),
                          _TrackingStat(
                            label: 'GPS',
                            value: '${tracking.routePoints.length}',
                            icon: Icons.satellite_alt,
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tracking.isActive) ...[
                            // Pause/Resume
                            FloatingActionButton(
                              heroTag: 'pause',
                              onPressed: tracking.isPaused ? tracking.resume : tracking.pause,
                              backgroundColor: Colors.orange,
                              child: Icon(tracking.isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                            ),
                            const SizedBox(width: 24),
                            // Stop
                            FloatingActionButton.large(
                              heroTag: 'stop',
                              onPressed: _stopTracking,
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.stop, color: Colors.white, size: 36),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  final TrackingProvider tracking;
  const _GradientPlaceholder({required this.tracking});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: tracking.currentMountain?.colors ?? [AppTheme.primary, AppTheme.primaryLight],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tracking.currentMountain?.emoji ?? '🏔️', style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                if (tracking.summitReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(l.summitReached, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (tracking.routePoints.isNotEmpty)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tracking.routePoints.length} GPS 포인트',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackingMap extends StatefulWidget {
  final TrackingProvider tracking;
  const _TrackingMap({required this.tracking});

  @override
  State<_TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<_TrackingMap> {
  NaverMapController? _mapController;
  int _lastPointCount = 0;

  @override
  void didUpdateWidget(covariant _TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRoute();
  }

  void _updateRoute() {
    final controller = _mapController;
    if (controller == null) return;

    final points = widget.tracking.routePoints;
    if (points.length == _lastPointCount) return;
    _lastPointCount = points.length;

    // 경로 폴리라인 갱신
    if (points.length >= 2) {
      controller.addOverlay(NPathOverlay(
        id: 'route',
        coords: points.map((p) => NLatLng(p.latitude, p.longitude)).toList(),
        color: AppTheme.primary,
        width: 4,
      ));
    }

    // 카메라를 마지막 위치로 이동
    if (points.isNotEmpty) {
      final last = points.last;
      controller.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(last.latitude, last.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mountain = widget.tracking.currentMountain;
    final defaultTarget = mountain != null
        ? NLatLng(mountain.latitude, mountain.longitude)
        : const NLatLng(37.55, 127.0);

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(target: defaultTarget, zoom: 14),
        locationButtonEnable: true,
      ),
      onMapReady: (controller) {
        _mapController = controller;

        // 산 마커
        if (mountain != null) {
          controller.addOverlay(NMarker(
            id: 'summit',
            position: NLatLng(mountain.latitude, mountain.longitude),
            caption: NOverlayCaption(text: '${mountain.emoji} ${mountain.name}'),
          ));
        }

        // 기존 경로 표시
        _updateRoute();
      },
    );
  }
}

class _TrackingStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _TrackingStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText)),
        Text(label, style: TextStyle(color: context.appTextSub, fontSize: 12)),
      ],
    );
  }
}
