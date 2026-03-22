import 'package:flutter/foundation.dart' show kIsWeb;
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
  final bool _mapError = false;
  final Map<String, Mountain> _detailedMountains = {};
  bool _loadingDetails = false;

  /// NaverMap Client ID가 설정되어 있는지 확인
  bool get _hasMapKey {
    final key = AppConstants.naverMapClientId;
    return key.isNotEmpty && key != 'YOUR_NAVER_MAP_CLIENT_ID';
  }

  bool get _useCardFallback => kIsWeb || !_hasMapKey || _mapError;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && _hasMapKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LocationProvider>().getCurrentPosition();
      });
    }
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
        builder: (context, state, _) {
          // 지도 준비된 상태에서 산 목록이 나중에 로드되면 마커 갱신
          if (_mapController != null && state.mountains.isNotEmpty) {
            _addMarkers(state.mountains);
          }
          return _useCardFallback
              ? _WebMapFallback(mountains: state.mountains, onTap: _showMountainDetail)
              : NaverMap(
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                      zoom: 10,
                    ),
                    locationButtonEnable: false,
                  ),
                  onMapReady: (controller) {
                    _mapController = controller;
                    _addMarkers(state.mountains);
                    _showMyLocationMarker();
                  },
                );
        },
      ),
      floatingActionButton: _useCardFallback
          ? null
          : FloatingActionButton(
              backgroundColor: AppTheme.primary,
              onPressed: _moveToCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
    );
  }

  void _addMarkers(List<Mountain> mountains) {
    final hasCoords = mountains.where((m) => m.latitude != 0 || m.longitude != 0).toList();
    if (hasCoords.isNotEmpty) {
      _addMarkersToMap(hasCoords);
    } else if (!_loadingDetails) {
      // 목록 API에 좌표가 없으면 상세 API에서 가져오기
      _loadMountainDetails(mountains);
    }
  }

  Future<void> _loadMountainDetails(List<Mountain> mountains) async {
    _loadingDetails = true;
    for (final m in mountains) {
      if (_detailedMountains.containsKey(m.id)) continue;
      try {
        final detail = await context.read<MountainProvider>().getMountainDetail(m.id);
        if (detail != null) {
          _detailedMountains[m.id] = detail;
        }
      } catch (e) {
        debugPrint('MapScreen._loadMountainDetails(${m.id}) error: $e');
      }
    }
    _loadingDetails = false;
    if (mounted && _detailedMountains.isNotEmpty) {
      _addMarkersToMap(_detailedMountains.values.toList());
    }
  }

  void _addMarkersToMap(List<Mountain> mountains) {
    for (final mountain in mountains) {
      if (mountain.latitude == 0 && mountain.longitude == 0) continue;
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
      _showMyLocationMarker();
    }
  }

  void _showMyLocationMarker() {
    final position = context.read<LocationProvider>().currentPosition;
    if (position == null || _mapController == null) return;

    final l = AppLocalizations.of(context)!;

    _mapController!.deleteOverlay(
      const NOverlayInfo(type: NOverlayType.marker, id: 'my_location'),
    );

    final marker = NMarker(
      id: 'my_location',
      position: NLatLng(position.latitude, position.longitude),
      caption: NOverlayCaption(text: l.myLocation),
      iconTintColor: Colors.blue,
    );
    _mapController!.addOverlay(marker);
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

/// 웹에서 NaverMap 대신 산 목록을 카드로 표시
class _WebMapFallback extends StatelessWidget {
  final List<Mountain> mountains;
  final Function(Mountain) onTap;

  const _WebMapFallback({required this.mountains, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (mountains.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: context.appTextSub),
            const SizedBox(height: 16),
            Text(l.mountainNotFound, style: TextStyle(color: context.appTextSub, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mountains.length,
      itemBuilder: (context, index) {
        final m = mountains[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onTap(m),
            child: MountainCard(mountain: m),
          ),
        );
      },
    );
  }
}
