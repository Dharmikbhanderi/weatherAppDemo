import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherappdemo/common/constans/string_constants.dart';
import 'package:weatherappdemo/common/enums/loading_status.dart';
import 'package:weatherappdemo/models/weatherData_model.dart';
import 'package:weatherappdemo/models/weather_model.dart';
import 'package:weatherappdemo/weather_data/bloc/weather_bloc.dart';
import 'package:weatherappdemo/weather_data/bloc/weather_event.dart';
import 'package:weatherappdemo/weather_data/bloc/weather_state.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  final cityFocusNode = FocusNode();
  bool fetchData = true;
  String isTrue = '';


  @override
  void initState() {
    super.initState();
    BlocProvider.of<WeatherBloc>(context).add(FetchWeatherByLocation());
    BlocProvider.of<WeatherBloc>(context).add(LoadSavedWeather());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state.status == LoadStatus.loading) {
          EasyLoading.show(dismissOnTap: false);
        } else if (state.status == LoadStatus.failure) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.message}'),
              behavior: SnackBarBehavior.floating,
              action: state.message!.startsWith('Location')
                  ? SnackBarAction(
                label: lblOpenSetting,
                onPressed: () {
                  Geolocator.openAppSettings();
                },
              ) : null,
            ),
          );
        } else if (state.status == LoadStatus.success) {
          EasyLoading.dismiss();
          fetchData = true;
        }else if (state.status == LoadStatus.loadingMore) {
          EasyLoading.dismiss();
          fetchData = false;
        }else if (state.status == LoadStatus.setData) {
          EasyLoading.dismiss();
        }
        },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: _buildAppBarTitle(state.currentWeather),
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: GestureDetector(
            onTap: (){
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: Column(
              children: [
                Padding(
                  padding:const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _cityController,
                    focusNode: cityFocusNode,
                    onSubmitted: (value){
                      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                      if (_cityController.text.isNotEmpty&&_cityController.text.trim().toLowerCase() != isTrue.toLowerCase()) {
                        BlocProvider.of<WeatherBloc>(context).add(FetchWeather(_cityController.text.trim()));
                      }else if(_cityController.text.trim().toLowerCase() == isTrue.toLowerCase()){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(cityValidation),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(cityNameValidation),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: enterCityName,
                      suffixIcon: IconButton(
                        icon:   const Icon(Icons.search),
                        onPressed: () {
                          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                          if (_cityController.text.isNotEmpty&&_cityController.text.trim().toLowerCase() != isTrue.toLowerCase()) {
                            BlocProvider.of<WeatherBloc>(context).add(FetchWeather(_cityController.text.trim()));
                          }else if(_cityController.text.trim().toLowerCase() == isTrue.toLowerCase()){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(cityValidation),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(cityNameValidation),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    onChanged: (value) {
                      BlocProvider.of<WeatherBloc>(context).add(FilterSavedWeather(value));
                    },
                  ),
                ),
                Expanded(child:
                fetchData==true?
                RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<WeatherBloc>(context).add(LoadSavedWeather());
                      BlocProvider.of<WeatherBloc>(context).add(FetchWeatherByLocation());
                    },
                    child: _buildSavedWeatherList(state.savedWeather??[])):
                _buildWeatherInfo(state.weather!))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(Weather weather) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(weather.cityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('${weather.temperature.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48)),
          Text(weather.condition, style: const TextStyle(fontSize: 24)),
          Text('Humidity: ${weather.humidity}%', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<WeatherBloc>(context).add(SaveWeather(weather));
              _cityController.clear();
              Future.delayed(const Duration(seconds: 1)).then((value) {
                BlocProvider.of<WeatherBloc>(context).add(LoadSavedWeather());
              });
            },
            child: const Text(saveWeatherData),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(Weather? currentLocationWeather) {
    if (currentLocationWeather == null) {
      return const Text(appName);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(appName),
        const Spacer(),
        const Icon(Icons.location_on, size: 25),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              currentLocationWeather.cityName,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5,),
            Text(
              '${currentLocationWeather.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavedWeatherList(List<Weather1> savedWeather) {
    return ListView.builder(
      itemCount: savedWeather.length,
      itemBuilder: (context, index) {
        final weather = savedWeather[index];
        isTrue = weather.cityName;
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getWeatherGradient(weather.condition),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(
                weather.cityName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    weather.condition,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(_getWeatherIcon(weather.condition), color: Colors.white, size: 30),
                  SizedBox(height: 4),
                  Text(
                    'Humidity: ${weather.humidity}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'drizzle':
        return Icons.grain;
      case 'haze':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  List<Color> _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return [Color(0xFF4A90E2), Color(0xFF76B1FF)];
      case 'clouds':
        return [Color(0xFF54717A), Color(0xFF8FA3AD)];
      case 'drizzle':
        return [Color(0xFF57575D), Color(0xFF80818A)];
      case 'haze':
        return [Color(0xFFAB7A5F), Color(0xFFCCAA8F)];
      case 'rain':
        return [Color(0xFF4A4E69), Color(0xFF7C7F91)];
      case 'snow':
        return [Color(0xFFE0E5EC), Color(0xFFF9F9F9)];
      case 'thunderstorm':
        return [Color(0xFF1F1C2C), Color(0xFF928DAB)];
      case 'mist':
        return [Color(0xFF999999), Color(0xFFB3B3B3)];
      default:
        return [Color(0xFF50A0C2), Color(0xFF7EC6E8)];
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}