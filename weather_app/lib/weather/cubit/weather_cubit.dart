/// fetchWeather(String? city) uses our weather repository to try and retrieve a weather object for the given city
/// refreshWeather() retrieves a new weather object using the weather repository given the current weather state
/// toggleUnits() toggles the state between Celsius and Fahrenheit
/// fromJson(Map<String, dynamic> json), toJson(WeatherState state) used for persistence

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_app/weather/models/models.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  final WeatherRepository _weatherRepository;

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();

  /**
   * Like blocs, cubit must be given an initial state
   */
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) {
      return;
    }

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      var _respositoryWeather = await _weatherRepository.getWeather(city);
      final weather = Weather.fromRepository(_respositoryWeather);

      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          /**
           * We could've set the weather directly, but we're using copyWith to provide an overwritern,formatted temperature value 
           */
          weather: weather.copyWith(temperature: Temperature(value: value))));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  void toggleUnits() {
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    final weather = state.weather;

    if (weather != Weather.empty) {
      final temperature = weather.temperature;
      final value = units.isCelsius
          ? temperature.value.toCelsius()
          : temperature.value.toFahrenheit();
      emit(
        state.copyWith(
          temperatureUnits: units,
          /**
           * Reflect the new temperature representation depending on the specified unit
           */
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    }
  }

  Future<void> refreshWeather() async {
    if (!state.status.isSuccess) return;
    if (state.weather == Weather.empty) return;
    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(state.weather.location),
      );
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    } on Exception {
      emit(state);
    }
  }
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
