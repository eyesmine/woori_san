import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  String _weatherMessage(Weather? weather) {
    if (weather == null) return '등산하기 딱 좋은 날씨!';

    final condition = weather.condition.toLowerCase();
    final temp = weather.temperature;

    if (condition.contains('rain') || condition.contains('drizzle')) {
      return '비 소식이 있어요. 우비를 챙기세요!';
    }
    if (condition.contains('snow')) {
      return '눈이 올 예정이에요. 방한 장비 필수!';
    }
    if (condition.contains('thunderstorm')) {
      return '천둥번개 예보! 산행을 미루는 게 좋겠어요.';
    }
    if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return '안개가 낄 수 있어요. 시야에 주의하세요.';
    }
    if (temp >= 33) {
      return '매우 더운 날씨! 충분한 수분 섭취 필수!';
    }
    if (temp >= 28) {
      return '더운 날씨에요. 물을 넉넉히 챙기세요.';
    }
    if (temp <= -5) {
      return '매우 추운 날씨! 방한 장비를 꼭 챙기세요.';
    }
    if (temp <= 3) {
      return '쌀쌀한 날씨에요. 따뜻하게 입으세요.';
    }
    if (condition.contains('cloud')) {
      return '구름이 있지만 산행하기 좋아요!';
    }
    return '등산하기 딱 좋은 날씨!';
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        '날씨 정보를 불러올 수 없어요',
                        style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                      )
                    else
                      Text(
                        state.isLoading ? '날씨 확인 중...' : _weatherMessage(weather),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      weather != null
                          ? '${weather.description} · ${weather.temperature.round()}°C · ${weather.windLabel}'
                          : state.isLoading ? '' : '맑음 · 12°C · 바람 약함',
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
