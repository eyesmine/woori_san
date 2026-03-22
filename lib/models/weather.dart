class Weather {
  final double temperature;
  final String condition;
  final String description;
  final double windSpeed;
  final int humidity;
  final String iconCode;
  final DateTime forecastDate;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? feelsLike;
  final int? pressure;
  final int? windDeg;
  final int? visibility;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.windSpeed,
    required this.humidity,
    required this.iconCode,
    required this.forecastDate,
    this.sunrise,
    this.sunset,
    this.feelsLike,
    this.pressure,
    this.windDeg,
    this.visibility,
  });

  String get emoji {
    return switch (condition) {
      'Clear' => '☀️',
      'Clouds' => '☁️',
      'Rain' || 'Drizzle' => '🌧️',
      'Snow' => '🌨️',
      'Thunderstorm' => '⛈️',
      'Mist' || 'Fog' || 'Haze' => '🌫️',
      _ => '🌤️',
    };
  }

  String get windLabel {
    if (windSpeed < 3) return '바람 약함';
    if (windSpeed < 7) return '바람 보통';
    return '바람 강함';
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'condition': condition,
    'description': description,
    'windSpeed': windSpeed,
    'humidity': humidity,
    'iconCode': iconCode,
    'forecastDate': forecastDate.toIso8601String(),
    'sunrise': sunrise?.toIso8601String(),
    'sunset': sunset?.toIso8601String(),
    'feelsLike': feelsLike,
    'pressure': pressure,
    'windDeg': windDeg,
    'visibility': visibility,
  };

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    temperature: (json['temperature'] as num).toDouble(),
    condition: json['condition'],
    description: json['description'],
    windSpeed: (json['windSpeed'] as num).toDouble(),
    humidity: json['humidity'],
    iconCode: json['iconCode'],
    forecastDate: DateTime.parse(json['forecastDate']),
    sunrise: json['sunrise'] != null ? DateTime.parse(json['sunrise']) : null,
    sunset: json['sunset'] != null ? DateTime.parse(json['sunset']) : null,
    feelsLike: json['feelsLike'] != null ? (json['feelsLike'] as num).toDouble() : null,
    pressure: json['pressure'] as int?,
    windDeg: json['windDeg'] as int?,
    visibility: json['visibility'] as int?,
  );

  factory Weather.fromOpenWeatherMap(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    return Weather(
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'],
      description: weather['description'],
      windSpeed: (wind['speed'] as num).toDouble(),
      humidity: main['humidity'],
      iconCode: weather['icon'],
      forecastDate: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      sunrise: json['sys']?['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['sys']['sunrise'] as int) * 1000)
          : null,
      sunset: json['sys']?['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['sys']['sunset'] as int) * 1000)
          : null,
      feelsLike: main['feels_like'] != null ? (main['feels_like'] as num).toDouble() : null,
      pressure: main['pressure'] as int?,
      windDeg: wind['deg'] as int?,
      visibility: json['visibility'] as int?,
    );
  }

  String get windDirection {
    if (windDeg == null) return '';
    const directions = ['북', '북동', '동', '남동', '남', '남서', '서', '북서'];
    return directions[((windDeg! + 22.5) ~/ 45) % 8];
  }

  String get hikingSuitability {
    final temp = temperature;
    final wind = windSpeed;
    final cond = condition.toLowerCase();

    if (cond.contains('thunderstorm')) return '⛔ 등산 부적합 — 천둥번개';
    if (cond.contains('snow') && wind > 7) return '⛔ 등산 부적합 — 폭설+강풍';
    if (wind > 10) return '⚠️ 주의 — 강풍';
    if (cond.contains('rain')) return '⚠️ 주의 — 비 예보';
    if (cond.contains('snow')) return '⚠️ 주의 — 눈 예보';
    if (temp >= 35) return '⚠️ 주의 — 폭염';
    if (temp <= -10) return '⚠️ 주의 — 한파';
    if (cond.contains('fog') || cond.contains('mist')) return '⚠️ 주의 — 시야 불량';
    if (temp >= 10 && temp <= 25 && wind < 5) return '✅ 최적 — 등산하기 딱 좋아요!';
    return '🟢 양호 — 등산 가능';
  }
}
