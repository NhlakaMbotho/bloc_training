import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart'
    hide
        Weather; //I'm guessing its to prevent confusion with the Weather we're defining
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits { fahrenheit, celsius }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}

@JsonSerializable()
class Temperature extends Equatable {
  final double value;

  const Temperature({required this.value});

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => [value];
}

@JsonSerializable()
class Weather extends Equatable {
  final WeatherCondition condition;
  final DateTime lastUpdated;
  final String location;
  final Temperature temperature;

  /// default constructor
  const Weather({
    required this.condition,
    required this.lastUpdated,
    required this.location,
    required this.temperature,
  });

  /// Weather instance from json data, taken care of by our generated function
  factory Weather.fromJson(Map<String, dynamic> json) {
    return _$WeatherFromJson(json);
  }

  /// Ability to create weather instance from from the weather repository model
  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
        condition: weather.condition,
        lastUpdated: DateTime.now(),
        location: weather.location,
        temperature: Temperature(value: weather.temperature));
  }

  /// is empty function
  static final empty = Weather(
    condition: WeatherCondition.unknown,
    lastUpdated: DateTime(0),
    temperature: const Temperature(value: 0),
    location: '--',
  );

  // Override get props (so we can easily get keys of an object)
  // I'm guessing this is also required because its a serializable object/model
  @override
  List<Object> get props => [condition, lastUpdated, location, temperature];

  /// must define a method to convert object to json
  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  // handy copy with function to set only the fields we need
  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? location,
    Temperature? temperature,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
    );
  }
}
