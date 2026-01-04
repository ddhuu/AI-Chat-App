class AiAgent {
  final String id;
  final String name;
  final String description;
  final String webhookUrl;
  final String icon;
  final AgentType type;

  AiAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.webhookUrl,
    required this.icon,
    required this.type,
  });

  factory AiAgent.fromJson(Map<String, dynamic> json) {
    return AiAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      webhookUrl: json['webhookUrl'] as String,
      icon: json['icon'] as String,
      type: AgentType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'webhookUrl': webhookUrl,
      'icon': icon,
      'type': type.value,
    };
  }
}

enum AgentType {
  weather('weather'),
  custom('custom');

  final String value;
  const AgentType(this.value);

  static AgentType fromString(String value) {
    return AgentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AgentType.custom,
    );
  }
}

class WeatherAgentRequest {
  final String city;

  WeatherAgentRequest({required this.city});

  Map<String, dynamic> toJson() {
    return {'city': city};
  }
}

class WeatherAgentResponse {
  final String status;
  final WeatherData? data;
  final String? error;

  WeatherAgentResponse({required this.status, this.data, this.error});

  factory WeatherAgentResponse.fromJson(Map<String, dynamic> json) {
    return WeatherAgentResponse(
      status: json['status'] as String,
      data: json['data'] != null
          ? WeatherData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }

  bool get isSuccess => status == 'success' && data != null;
}

class WeatherData {
  final String city;
  final String time;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String weather;
  final double windSpeed;

  WeatherData({
    required this.city,
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.weather,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['city'] as String,
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: json['humidity'] as int,
      weather: json['weather'] as String,
      windSpeed: (json['wind_speed'] as num).toDouble(),
    );
  }

  String toFormattedMessage() {
    return '''
🌤️ **Thời tiết hiện tại tại $city**

🌡️ Nhiệt độ: $temperature°C (cảm giác như $feelsLike°C)
☁️ Trạng thái: $weather
💧 Độ ẩm: $humidity%
💨 Gió: $windSpeed m/s
''';
  }
}
