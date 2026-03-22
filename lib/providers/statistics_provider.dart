import 'package:flutter/material.dart';
import '../models/hiking_record.dart';
import '../repositories/plan_repository.dart';

class StatisticsProvider extends ChangeNotifier {
  final PlanRepository _planRepo;

  late List<HikingRecord> _records;

  StatisticsProvider(this._planRepo) {
    _records = _planRepo.getRecords();
  }

  List<HikingRecord> get records => _records;
  int get totalHikes => _records.length;

  double get totalDistanceKm {
    double total = 0;
    for (final r in _records) {
      total += r.distanceKm;
    }
    return total;
  }

  String get totalDistance => '${totalDistanceKm.toStringAsFixed(1)}km';

  int get totalElevationGain {
    int total = 0;
    for (final r in _records) {
      total += r.elevationGain ?? 0;
    }
    return total;
  }

  // --- Best Records ---

  String get longestDistance {
    if (_records.isEmpty) return '-';
    double maxDist = 0;
    for (final r in _records) {
      if (r.distanceKm > maxDist) maxDist = r.distanceKm;
    }
    return '${maxDist.toStringAsFixed(1)}km';
  }

  String get highestElevation {
    if (_records.isEmpty) return '-';
    int maxElev = 0;
    for (final r in _records) {
      final e = r.elevationGain ?? 0;
      if (e > maxElev) maxElev = e;
    }
    return '${maxElev}m';
  }

  String get longestDuration {
    if (_records.isEmpty) return '-';
    int maxMinutes = 0;
    String maxDurationStr = '-';
    for (final r in _records) {
      final mins = _parseDurationMinutes(r.duration);
      if (mins > maxMinutes) {
        maxMinutes = mins;
        maxDurationStr = r.duration;
      }
    }
    return maxDurationStr;
  }

  /// Parse duration string like "4h 23m" or "2시간 30분" into total minutes
  int _parseDurationMinutes(String duration) {
    int total = 0;
    // Match hours
    final hMatch = RegExp(r'(\d+)\s*[hH시]').firstMatch(duration);
    if (hMatch != null) {
      total += int.parse(hMatch.group(1)!) * 60;
    }
    // Match minutes
    final mMatch = RegExp(r'(\d+)\s*[mM분]').firstMatch(duration);
    if (mMatch != null) {
      total += int.parse(mMatch.group(1)!);
    }
    return total;
  }

  // --- Hiking Calendar ---

  Set<DateTime> get hikingDates {
    final dates = <DateTime>{};
    for (final r in _records) {
      if (r.startTime != null) {
        dates.add(DateTime(r.startTime!.year, r.startTime!.month, r.startTime!.day));
      } else {
        // Fallback: parse date string "2025.01.20" or "2025-01-20"
        final parsed = _parseDate(r.date);
        if (parsed != null) {
          dates.add(DateTime(parsed.year, parsed.month, parsed.day));
        }
      }
    }
    return dates;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Handle "2025.01.20" format
      final cleaned = dateStr.replaceAll('.', '-');
      return DateTime.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  // --- Unique regions ---

  Set<String> get uniqueRegions {
    final regions = <String>{};
    for (final r in _records) {
      // Extract region from mountain name or use the mountain field
      regions.add(r.mountain);
    }
    return regions;
  }

  void refresh() {
    _records = _planRepo.getRecords();
    notifyListeners();
  }
}
