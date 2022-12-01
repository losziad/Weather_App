import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:weather_1/components/weather_item.dart';
import 'package:weather_1/constants.dart';
import 'package:weather_1/ui/details_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();
  static String API_KEY = 'f8b7d93209ff4733bb3160747222911';

  String location = 'London'; //default location
  String weatherIcon = 'heavycloud.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //API Call
  String searchWeatherAPI = 'https://api.weatherapi.com/v1/forecast.json?key=' +
      API_KEY +
      '&days=7&q=';

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult = await http.get(
        Uri.parse(searchWeatherAPI + searchText),
      );
      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');
      var locationData = weatherData['location'];
      var currentWeather = weatherData['current'];

      setState(() {
        location = getShortLocationName(locationData['name']);
        var parsedDate =
            DateTime.parse(locationData['localtime'].substring(0, 10));
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;

        //update weather
        currentWeatherStatus = currentWeather['condition']['text'];
        weatherIcon =
            currentWeatherStatus.replaceAll(' ', '').toLowerCase() + '.png';
        temperature = currentWeather['temp_c'].toInt();
        windSpeed = currentWeather['wind_kph'].toInt();
        humidity = currentWeather['humidity'].toInt();
        cloud = currentWeather['cloud'].toInt();

        //forecast data
        dailyWeatherForecast = weatherData['forecast']['forecastday'];
        hourlyWeatherForecast = dailyWeatherForecast[0]['hour'];
        print(dailyWeatherForecast);
      });
    } catch (error) {}
  }

  //function to return the first two name of the string location
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(' ');
    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + ' ' + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return ' ';
    }
  }

  @override
  void initState() {
    fetchWeatherData(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.only(
            top: 70,
            left: 10,
            right: 10,
          ),
          color: _constants.primaryColor.withOpacity(
            0.1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                height: size.height * 0.7,
                decoration: BoxDecoration(
                  gradient: _constants.linearGradientBlue,
                  boxShadow: [
                    BoxShadow(
                      color: _constants.primaryColor.withOpacity(0.5),
                      spreadRadius: 5.0,
                      blurRadius: 7.0,
                      offset: const Offset(0, 3.0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/menu.png',
                          width: 40.0,
                          height: 40.0,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/pin.png',
                              width: 20.0,
                            ),
                            const SizedBox(
                              width: 2.0,
                            ),
                            Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _cityController.clear();
                                showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => SingleChildScrollView(
                                    controller:
                                        ModalScrollController.of(context),
                                    child: Container(
                                      height: size.height * 0.2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 70.0,
                                            child: Divider(
                                              thickness: 3.5,
                                              color: _constants.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          TextField(
                                            onChanged: (searchText) {
                                              fetchWeatherData(searchText);
                                            },
                                            controller: _cityController,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: _constants.primaryColor,
                                              ),
                                              suffixIcon: GestureDetector(
                                                onTap: () =>
                                                    _cityController.clear(),
                                                child: Icon(
                                                  Icons.close,
                                                  color:
                                                      _constants.primaryColor,
                                                ),
                                              ),
                                              hintText: 'Search city e.g. London',
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      _constants.primaryColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/profile.png',
                            width: 40.0,
                            height: 40.0,
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: SizedBox(
                        height: 160.0,
                        child: Image.asset(
                          'assets/' + weatherIcon,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Text(
                            temperature.toString(),
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = _constants.shader,
                            ),
                          ),
                        ),
                        Text(
                          'o',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = _constants.shader,
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        currentWeatherStatus,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        currentDate,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: const Divider(
                        color: Colors.white70,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherItem(
                            text: '',
                            value: windSpeed.toInt(),
                            unit: ' km/h',
                            imageUri: 'assets/windspeed.png',
                          ),
                          WeatherItem(
                            text: '',
                            value: humidity.toInt(),
                            unit: ' %',
                            imageUri: 'assets/humidity.png',
                          ),
                          WeatherItem(
                            text: '',
                            value: cloud.toInt(),
                            unit: ' %',
                            imageUri: 'assets/cloud.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                height: size.height * 0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                dailyForecastWeather: dailyWeatherForecast,
                              ),
                            ),
                          ),
                          child: Text(
                            'Forecasts',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: _constants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    SizedBox(
                      height: 110.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          String currentTime =
                              DateFormat('HH:mm:ss').format(DateTime.now());
                          String currentHour = currentTime.substring(0, 2);

                          String forecastTime = hourlyWeatherForecast[index]['time']
                              .substring(11, 16);
                          String forecastHour = hourlyWeatherForecast[index]['time']
                              .substring(11, 16);

                          String forecastWeatherName =
                              hourlyWeatherForecast[index]['condition']['text'];
                          String forecastWeatherIcon = forecastWeatherName
                                  .replaceAll(' ', '')
                                  .toLowerCase() +
                              '.png';
                          String forecastTemperature =
                              hourlyWeatherForecast[index]['temp_c']
                                  .round()
                                  .toString();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                            ),
                            margin: const EdgeInsets.only(right: 20.0),
                            width: 65.0,
                            decoration: BoxDecoration(
                              color: currentHour == forecastHour
                                  ? Colors.white
                                  : _constants.primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                  50.0,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1.0),
                                  blurRadius: 5.0,
                                  color:
                                      _constants.primaryColor.withOpacity(0.2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  forecastTime,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    color: _constants.greyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Image.asset(
                                  'assets/' + forecastWeatherIcon,
                                  width: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      forecastTemperature,
                                      style: TextStyle(
                                        color: _constants.greyColor,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'o',
                                      style: TextStyle(
                                        color: _constants.greyColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.0,
                                        fontFeatures: const [
                                          FontFeature.enable('sups'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
