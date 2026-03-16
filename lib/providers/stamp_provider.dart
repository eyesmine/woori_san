import 'package:flutter/material.dart';
import '../models/stamp.dart';
import '../repositories/stamp_repository.dart';

class StampProvider extends ChangeNotifier {
  final StampRepository _repo;

  late List<Stamp> _stamps;

  StampProvider(this._repo) {
    _stamps = _repo.getAll();
  }

  List<Stamp> get stamps => _stamps;
  int get totalStamped => _stamps.where((m) => m.isStamped).length;
  int get togetherStamped => _stamps.where((m) => m.isTogetherStamped).length;
  List<Stamp> get togetherStamps => _stamps.where((m) => m.isTogetherStamped).toList();

  void toggleStamp(int index, {bool together = false}) {
    if (index < 0 || index >= _stamps.length) return;
    final m = _stamps[index];
    m.isStamped = !m.isStamped;
    if (m.isStamped) {
      m.stampDate = _formatDate(DateTime.now());
      if (together) m.isTogetherStamped = true;
    } else {
      m.isTogetherStamped = false;
      m.stampDate = null;
    }
    _repo.saveAll(_stamps);
    notifyListeners();
  }

  void toggleTogetherStamp(int index) {
    if (index < 0 || index >= _stamps.length) return;
    final m = _stamps[index];
    if (!m.isStamped) return;
    m.isTogetherStamped = !m.isTogetherStamped;
    _repo.saveAll(_stamps);
    notifyListeners();
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}
