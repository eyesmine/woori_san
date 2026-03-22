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
    _local.saveAll(_favoriteIds);
    notifyListeners();
  }
}
