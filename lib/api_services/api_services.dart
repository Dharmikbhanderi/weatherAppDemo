import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weatherappdemo/common/constans/string_constants.dart';

class WeatherApiService {
  static const String _apiKey = '1b426811b4d261ed1c1a6f5865c813f6';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(msgFailedWeatherData);
    }
  }

  Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(msgFailedWeatherData);
    }
  }
}