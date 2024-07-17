import 'package:weatherappdemo/common/enums/loading_status.dart';
import 'package:weatherappdemo/models/weatherData_model.dart';
import 'package:weatherappdemo/models/weather_model.dart';

class WeatherState{
    WeatherState({
    this.status = LoadStatus.initial,
    this.weather,
    this.currentWeather,
    this.message,
    this.savedWeather,
  });

  final LoadStatus status;
  Weather? weather;
  Weather? currentWeather;
  final String? message;
  final List<Weather1>? savedWeather;

  WeatherState copyWith({
    LoadStatus? status,
    Weather? weather,
    Weather? currentWeather,
    String? message,
    List<Weather1>? savedWeather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      currentWeather: currentWeather ?? this.currentWeather,
      message: message ?? this.message,
      savedWeather: savedWeather ?? this.savedWeather,
    );
  }

  @override
  List<Object?> get props => [
    status,weather,message,savedWeather,currentWeather
  ];
}