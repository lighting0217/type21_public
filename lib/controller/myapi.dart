// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../library/weather/models/CurrentWetherData.dart';
import '../library/weather/models/DailyWeatherData.dart';
import '../library/weather/models/HourlyWeatherData.dart';
import '../library/weather/models/location_name.dart';
import '../library/weather/models/WeatherData.dart';

// Google API key for location services
const googleAPIKey = "your google api key";
// OpenWeatherMap API key for weather data
const openWeatherAPIKey = "your open weather api key";

class Constants {
  static String appId = " ";
  static String apiKey = " ";
  static String messagingSenderId = " ";
  static String projectId = " ";
}

class WeatherDataFetcher {
  Future<WeatherData> fetchData(double lat, double lng) async {
    final url = _buildAPIUrl(lat, lng);
    final response = await http.get(Uri.parse(url));
    final jsonData = jsonDecode(response.body);
    final currentWeatherData = CurrentWeatherData.fromJson(jsonData);
    final hourlyWeatherData = HourlyWeatherData.fromJson(jsonData);
    final dailyWeatherData = DailyWeatherData.fromJson(jsonData);
    final locationNameJson = await fetchLocationName(lat, lng);
    final locationNameData = locationNameJson != null
        ? LocationNameData.fromJson(locationNameJson)
        : null;
    return WeatherData(currentWeatherData, hourlyWeatherData, dailyWeatherData,
        locationNameData);
  }

  String _buildAPIUrl(double lat, double lng) {
    return "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lng&appid=$openWeatherAPIKey&exclude=minutely&units=metric&lang=th";
  }

  Future<Map<String, dynamic>?> fetchLocationName(
      double lat, double lng) async {
    try {
      final url = _buildLocationAPIUrl(lat, lng);
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return jsonResponse[0];
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    return null;
  }

  String _buildLocationAPIUrl(double lat, double lng) {
    return 'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lng&limit=1&appid=$openWeatherAPIKey&lang=th';
  }
}

class GoogleServices {
  Future<Position> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
