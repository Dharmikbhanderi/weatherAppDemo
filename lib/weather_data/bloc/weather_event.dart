import 'package:equatable/equatable.dart';
import 'package:weatherappdemo/models/weather_model.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final String cityName;

  const FetchWeather(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class SaveWeather extends WeatherEvent {
  final Weather weather;

  const SaveWeather(this.weather);

  @override
  List<Object> get props => [weather];
}

class LoadSavedWeather extends WeatherEvent {}

class FilterSavedWeather extends WeatherEvent {
  final dynamic query;

  const FilterSavedWeather(this.query);

  @override
  List<Object> get props => [query];
}

class FetchWeatherByLocation extends WeatherEvent {}