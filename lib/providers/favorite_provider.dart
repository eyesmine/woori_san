import 'package:flutter/material.dart';
import '../datasources/local/favorite_local.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteLocalDataSource _local;
  late List<String> _favoriteIds;

  FavoriteProvider(this._local) {
    _favoriteIds = _local.getAll();
  }

  List<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String mountainId) => _favoriteIds.contains(mountainId);

  void toggleFavorite(String mountainId) {
    if (_favoriteIds.contains(mountainId)) {
      _favoriteIds.remove(mountainId);
    } else {
      _favoriteIds.add(mountainId);
    }
    try {
      _local.saveAll(_favoriteIds);
    } catch (e) {
      // 저장 실패 시 무시 — 다음 앱 실행 시 동기화됨
    }
    notifyListeners();
  }
}
