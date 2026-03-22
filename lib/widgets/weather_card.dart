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

        return GestureDetector(
          onTap: weather != null ? () => _showWeatherDetail(context, weather, l) : null,
          child: Container(
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
                    if (weather?.sunrise != null && weather?.sunset != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text('${l.sunrise} ${DateFormat('HH:mm').format(weather!.sunrise!)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.nightlight_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text('${l.sunset} ${DateFormat('HH:mm').format(weather.sunset!)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  void _showWeatherDetail(BuildContext context, Weather weather, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),

              // 이모지 + 기온
              Center(child: Text(weather.emoji, style: const TextStyle(fontSize: 56))),
              const SizedBox(height: 8),
              Center(child: Text('${weather.temperature.round()}°C', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800))),
              Center(child: Text(weather.description, style: TextStyle(fontSize: 16, color: Colors.grey.shade600))),
              const SizedBox(height: 16),

              // 등산 적합도
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  weather.hikingSuitability,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // 상세 정보 그리드
              Row(
                children: [
                  Expanded(child: _DetailItem(icon: Icons.thermostat_outlined, label: l.weatherFeelsLike, value: '${weather.feelsLike?.round() ?? '-'}°C')),
                  Expanded(child: _DetailItem(icon: Icons.water_drop_outlined, label: l.weatherHumidity, value: '${weather.humidity}%')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _DetailItem(icon: Icons.air, label: l.weatherWind, value: '${weather.windSpeed}m/s ${weather.windDirection}')),
                  Expanded(child: _DetailItem(icon: Icons.compress, label: l.weatherPressure, value: '${weather.pressure ?? '-'}hPa')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _DetailItem(icon: Icons.visibility_outlined, label: l.weatherVisibility, value: weather.visibility != null ? '${(weather.visibility! / 1000).toStringAsFixed(1)}km' : '-')),
                  if (weather.sunrise != null)
                    Expanded(child: _DetailItem(icon: Icons.wb_sunny_outlined, label: l.sunrise, value: DateFormat('HH:mm').format(weather.sunrise!))),
                  if (weather.sunset != null)
                    Expanded(child: _DetailItem(icon: Icons.nightlight_outlined, label: l.sunset, value: DateFormat('HH:mm').format(weather.sunset!))),
                  if (weather.sunrise == null && weather.sunset == null)
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(10) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4895D0)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
