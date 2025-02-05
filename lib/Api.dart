import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AQIScreen extends StatefulWidget {
  @override
  _AirQualityScreenState createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AQIScreen> {
  String city = "Loading...";
  int aqi = 0;
  double temperature = 0.0;
  bool isLoading = true;

  Future<void> fetchAirQuality() async {
    final latitude = 13.7563;
    final longitude = 100.5018;

    final url = Uri.parse(
        "https://api.waqi.info/feed/geo:$latitude;$longitude/?token=837bcfde7f7bb0a55f299d2642ef6813811f0257");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == "ok") {
          setState(() {
            city = data['data']['city']['name'];
            aqi = data['data']['aqi'];
            temperature = data['data']['iaqi']['t']['v'].toDouble();
            isLoading = false;
          });
        } else {
          setState(() {
            city = "Error";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          city = "Error";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        city = "Error";
        isLoading = false;
      });
    }
  }

  Color getAqiColor(int aqi) {
    if (aqi <= 50) {
      return Colors.green;
    } else if (aqi <= 100) {
      return Colors.yellow;
    } else if (aqi <= 150) {
      return Colors.orange;
    } else if (aqi <= 200) {
      return Colors.red;
    } else if (aqi <= 300) {
      return Colors.purple;
    } else {
      return Colors.brown;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAirQuality();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          "Air Quality Index (AQI)",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Color(0xFF3A85AA),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A85AA)),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedDefaultTextStyle(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A85AA),
                        fontFamily: 'Roboto',
                      ),
                      duration: Duration(milliseconds: 500),
                      child: Text(city),
                    ),
                    SizedBox(height: 20),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: getAqiColor(aqi),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "$aqi",
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            aqi > 150 ? "Unhealthy" : "Good",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        "Temperature: ${temperature.toStringAsFixed(1)}°C",
                        key: ValueKey<double>(temperature),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: fetchAirQuality,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3A85AA),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blueAccent,
                      ),
                      child: Text(
                        "Refresh",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
