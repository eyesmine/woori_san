import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class RouteMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> routePoints;
  final double height;

  const RouteMapWidget({super.key, required this.routePoints, this.height = 250});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (routePoints.isEmpty) {
      return _PlaceholderContainer(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 40, color: context.appTextSub),
            const SizedBox(height: 8),
            Text(l.noRouteData, style: TextStyle(color: context.appTextSub, fontSize: 14)),
          ],
        ),
      );
    }

    final hasMapClient = !kIsWeb && AppConstants.naverMapClientId.isNotEmpty;
    if (!hasMapClient) {
      return _PlaceholderContainer(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route, size: 40, color: Colors.white70),
            const SizedBox(height: 8),
            Text('${l.routeMap} (${routePoints.length} points)', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: _NaverRouteMap(routePoints: routePoints),
    );
  }
}

class _PlaceholderContainer extends StatelessWidget {
  final double height;
  final Widget child;
  const _PlaceholderContainer({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
        ),
      ),
      child: child,
    );
  }
}

class _NaverRouteMap extends StatelessWidget {
  final List<Map<String, dynamic>> routePoints;
  const _NaverRouteMap({required this.routePoints});

  @override
  Widget build(BuildContext context) {
    final coords = routePoints.map((p) => NLatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble())).toList();
    if (coords.isEmpty) return const SizedBox.shrink();

    double minLat = coords.first.latitude, maxLat = coords.first.latitude;
    double minLng = coords.first.longitude, maxLng = coords.first.longitude;
    for (final c in coords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(target: NLatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2), zoom: 14),
        scrollGesturesEnable: true,
        zoomGesturesEnable: true,
        rotationGesturesEnable: false,
        tiltGesturesEnable: false,
      ),
      onMapReady: (controller) {
        controller.addOverlay(NPathOverlay(id: 'route_path', coords: coords, color: AppTheme.primary, outlineColor: AppTheme.primary.withAlpha(80), width: 4));
        final startMarker = NMarker(id: 'start_marker', position: coords.first, caption: NOverlayCaption(text: AppLocalizations.of(context)?.startPoint ?? 'Start', textSize: 12, color: AppTheme.primary));
        startMarker.setIconTintColor(AppTheme.primary);
        controller.addOverlay(startMarker);
        if (coords.length > 1) {
          final endMarker = NMarker(id: 'end_marker', position: coords.last, caption: NOverlayCaption(text: AppLocalizations.of(context)?.endPoint ?? 'End', textSize: 12, color: AppTheme.accent));
          endMarker.setIconTintColor(AppTheme.accent);
          controller.addOverlay(endMarker);
          controller.updateCamera(NCameraUpdate.fitBounds(NLatLngBounds(southWest: NLatLng(minLat, minLng), northEast: NLatLng(maxLat, maxLng)), padding: const EdgeInsets.all(40)));
        }
      },
    );
  }
}
