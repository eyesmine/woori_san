import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/mountain_provider.dart';
import '../providers/location_provider.dart';
import '../models/mountain.dart';
import '../widgets/mountain_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().getCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(l.mountainMap, style: TextStyle(fontWeight: FontWeight.w700, color: context.appText)),
      ),
      body: Consumer<MountainProvider>(
        builder: (context, state, _) => NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(AppConstants.defaultLat, AppConstants.defaultLng),
              zoom: 10,
            ),
            locationButtonEnable: true,
          ),
          onMapReady: (controller) {
            _mapController = controller;
            _addMarkers(state.mountains);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _moveToCurrentLocation,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  void _addMarkers(List<Mountain> mountains) {
    for (final mountain in mountains) {
      final marker = NMarker(
        id: mountain.id,
        position: NLatLng(mountain.latitude, mountain.longitude),
        caption: NOverlayCaption(text: '${mountain.emoji} ${mountain.name}'),
      );
      marker.setOnTapListener((overlay) {
        _showMountainDetail(mountain);
      });
      _mapController?.addOverlay(marker);
    }
  }

  void _moveToCurrentLocation() {
    final position = context.read<LocationProvider>().currentPosition;
    if (position != null) {
      _mapController?.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 13,
        ),
      );
    }
  }

  void _showMountainDetail(Mountain mountain) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(mountain.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(mountain.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.appText)),
            Text('${mountain.location} · ${mountain.height}m · ${mountain.distance}', style: TextStyle(color: context.appTextSub, fontSize: 14)),
            const SizedBox(height: 12),
            Text(mountain.description, style: TextStyle(color: context.appText, fontSize: 15, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DifficultyTag(difficulty: mountain.difficulty),
                const SizedBox(width: 10),
                Text(mountain.time, style: TextStyle(color: context.appTextSub)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/mountain/${mountain.id}');
                },
                child: Text(l.mountainDetail),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
