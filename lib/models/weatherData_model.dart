import 'package:equatable/equatable.dart';

class Weather1 extends Equatable {
  final String cityName;
  final double temperature;
  final String condition;
  final double humidity;

  const Weather1({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
  });

  factory Weather1.fromJson(Map<String, dynamic> json) {
    return Weather1(
      cityName: json['cityName'] as String? ?? 'Unknown',
      temperature: _parseDouble(json['temperature']) ?? 0.0,
      condition: json['condition'] as String? ?? 'Unknown',
      humidity: _parseDouble(json['humidity']) ?? 0.0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
    };
  }

  @override
  List<Object> get props => [cityName, temperature, condition, humidity];
}