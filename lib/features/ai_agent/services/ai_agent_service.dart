import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../models/ai_agent_model.dart';
import '../prompts/weather_agent_prompts.dart';

class AiAgentService {
  final ApiService _apiService;

  AiAgentService(this._apiService);

  Future<WeatherAgentResponse> callWeatherAgent({
    required String webhookUrl,
    required String city,
  }) async {

    try {
      final request = WeatherAgentRequest(city: city);

      final response = await _apiService.dio.post(
        webhookUrl,
        data: request.toJson(),
        options: Options(extra: {'requireToken': false}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WeatherAgentResponse.fromJson(response.data);
      }

      throw Exception('Failed to get weather data');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return WeatherAgentResponse(
            status: 'error',
            error: e.response?.data['message'] ?? 'Failed to get weather data',
          );
        }
      }
      return WeatherAgentResponse(
        status: 'error',
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Extract city from user message using AI
  Future<String> extractCityFromMessage(String message) async {
    try {
     
      final prompt = WeatherAgentPrompts.getCityExtractionPrompt(message);

      final response = await _apiService.dio.post(
        ApiConstants.aiChatMessages,
        data: {
          'content': prompt,
          'model': 'gpt-4o-mini',
          'history': [],
          'stream': false,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        final city =
            (response.data['message'] ??
                    response.data['answer'] ??
                    'Ho Chi Minh')
                .toString()
                .trim();

        return city;
      }
      return 'Ho Chi Minh';
    } catch (e) {
      return 'Ho Chi Minh';
    }
  }

  /// Format weather response using AI
  Future<String> formatWeatherResponse(WeatherData weatherData) async {
    try {

      final weatherJson =
          '''
City: ${weatherData.city}
Time: ${weatherData.time}
Temperature: ${weatherData.temperature}°C
Feels Like: ${weatherData.feelsLike}°C
Weather: ${weatherData.weather}
Humidity: ${weatherData.humidity}%
Wind Speed: ${weatherData.windSpeed} m/s
''';

      final prompt = WeatherAgentPrompts.getResponseFormattingPrompt(
        weatherJson,
      );

      final response = await _apiService.dio.post(
        ApiConstants.aiChatMessages,
        data: {
          'content': prompt,
          'model': 'gpt-4o-mini',
          'history': [],
          'stream': false,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        final formattedMessage =
            (response.data['message'] ?? response.data['answer'] ?? '')
                .toString()
                .trim();

        return formattedMessage;
      }
      return weatherData.toFormattedMessage();
    } catch (e) {
      return weatherData.toFormattedMessage();
    }
  }
}
