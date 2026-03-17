import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/weather.dart';
import '../providers/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  String get _nextSaturday {
    final now = DateTime.now();
    final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    final saturday = now.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
    return DateFormat('M월 d일 (E)', 'ko_KR').format(saturday);
  }

  String _weatherMessage(AppLocalizations l, Weather? weather) {
    if (weather == null) return l.weatherDefault;

    final condition = weather.condition.toLowerCase();
    final temp = weather.temperature;

    if (condition.contains('rain') || condition.contains('drizzle')) {
      return l.weatherRain;
    }
    if (condition.contains('snow')) {
      return l.weatherSnow;
    }
    if (condition.contains('thunderstorm')) {
      return l.weatherThunder;
    }
    if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return l.weatherFog;
    }
    if (temp >= 33) {
      return l.weatherVeryHot;
    }
    if (temp >= 28) {
      return l.weatherHot;
    }
    if (temp <= -5) {
      return l.weatherVeryCold;
    }
    if (temp <= 3) {
      return l.weatherCold;
    }
    if (condition.contains('cloud')) {
      return l.weatherCloudy;
    }
    return l.weatherDefault;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<WeatherProvider>(
      builder: (context, state, _) {
        final weather = state.weather;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF74B3CE), Color(0xFF4895D0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF4895D0).withAlpha(77), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              if (state.isLoading)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white70),
                )
              else
                Text(weather?.emoji ?? '☀️', style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nextSaturday, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    if (state.error != null)
                      Text(
                        l.weatherError,
                        style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                      )
                    else
                      Text(
                        state.isLoading ? l.weatherLoading : _weatherMessage(l, weather),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      weather != null
                          ? '${weather.description} · ${weather.temperature.round()}°C · ${weather.windLabel}'
                          : state.isLoading ? '' : l.weatherFallback,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
