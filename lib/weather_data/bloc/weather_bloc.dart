import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherappdemo/api_services/api_services.dart';
import 'package:weatherappdemo/common/constans/string_constants.dart';
import 'package:weatherappdemo/common/enums/loading_status.dart';
import 'package:weatherappdemo/models/weatherData_model.dart';
import 'package:weatherappdemo/models/weather_model.dart';
import 'package:weatherappdemo/weather_data/bloc/weather_event.dart';
import 'package:weatherappdemo/weather_data/bloc/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiService _weatherApiService;
  final FirebaseFirestore firebaseStore;
    List<Weather1> _allSavedWeather = [];
    List<Weather1> _filteredWeather = [];

  WeatherBloc(this._weatherApiService, this.firebaseStore) : super(WeatherState()) {
    on<FetchWeather>(_onFetchWeather);
    on<FetchWeatherByLocation>(_onFetchWeatherByLocation);
    on<SaveWeather>(_onSaveWeather);
    on<LoadSavedWeather>(_onLoadSavedWeather);
    on<FilterSavedWeather>(_onFilterSavedWeather);
  }

  Future<void> _onFetchWeatherByLocation(FetchWeatherByLocation event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(state.copyWith(
              message: locationPermissionDenied,
              status: LoadStatus.failure
          ));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
            message: permissionPermanentlyDenied,
            status: LoadStatus.failure
        ));
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      final weatherData = await _weatherApiService.getWeatherByCoordinates(position.latitude, position.longitude);
      final weather = Weather.fromJson(weatherData);
      emit(state.copyWith(status: LoadStatus.setData, currentWeather: weather));
    } catch (e) {
      emit(state.copyWith(message: 'Failed to get weather: ${e.toString()}', status: LoadStatus.failure));
    }
  }

  Future<void> _onFetchWeather(FetchWeather event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading));
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.none) {
      emit(state.copyWith(message: msgCheckConnection, status: LoadStatus.failure));
      return;
    }else{
      try {
        final weatherData = await _weatherApiService.getWeather(event.cityName);
        final weather = Weather.fromJson(weatherData);
        emit(state.copyWith(status: LoadStatus.loadingMore, weather: weather));
      } catch (e) {
        emit(state.copyWith(message: msgEnterValidCity, status: LoadStatus.failure));

      }
    }

  }

  Future<void> _onSaveWeather(SaveWeather event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      await firebaseStore.collection('weather').add(event.weather.toJson());
    } catch (e) {
      emit(state.copyWith(message: 'Failed to save weather: ${e.toString()}', status: LoadStatus.failure));
    }
  }


  FutureOr<void> _onLoadSavedWeather(LoadSavedWeather event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      final snapshot = await firebaseStore.collection('weather').get();
      _allSavedWeather = snapshot.docs.map((doc) => Weather1.fromJson(doc.data())).toList();
      _allSavedWeather.sort((a, b) => a.cityName.toLowerCase().compareTo(b.cityName.toLowerCase()));
      _filteredWeather = List.from(_allSavedWeather);
      emit(state.copyWith(status: LoadStatus.success, savedWeather: _filteredWeather));
    } catch (e) {
      emit(state.copyWith(message: e.toString(), status: LoadStatus.failure));

    }
  }

  void _onFilterSavedWeather(FilterSavedWeather event, Emitter<WeatherState> emit) {
    emit(state.copyWith(status: LoadStatus.loading));
    if (event.query.isEmpty) {
      _filteredWeather = List.from(_allSavedWeather);
    } else {
      _filteredWeather = _allSavedWeather
          .where((weather) {
        final matchesCity = weather.cityName.toLowerCase().contains(event.query.toLowerCase());
        final matchesTemperature = weather.temperature.toString().contains(event.query.toString());
        final matchesHumidity = weather.humidity.toString().contains(event.query.toString());
        return matchesCity || matchesTemperature ||matchesHumidity;
      }).toList();
    }
    emit(state.copyWith(status: LoadStatus.success, savedWeather: _filteredWeather));

  }
}