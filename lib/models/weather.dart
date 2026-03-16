class Weather {
  final double temperature;
  final String condition;
  final String description;
  final double windSpeed;
  final int humidity;
  final String iconCode;
  final DateTime forecastDate;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.windSpeed,
    required this.humidity,
    required this.iconCode,
    required this.forecastDate,
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
  };

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    temperature: (json['temperature'] as num).toDouble(),
    condition: json['condition'],
    description: json['description'],
    windSpeed: (json['windSpeed'] as num).toDouble(),
    humidity: json['humidity'],
    iconCode: json['iconCode'],
    forecastDate: DateTime.parse(json['forecastDate']),
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
    );
  }
}
