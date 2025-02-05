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
    // Latitude and Longitude for Bangkok
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
            temperature =
                data['data']['iaqi']['t']['v'].toDouble(); // ดึงค่าอุณหภูมิ
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Air Quality Index (AQI)",
          style: TextStyle(
              fontSize: 25, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color.fromARGB(255, 58, 133, 170),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    city,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: getAqiColor(aqi),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$aqi",
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          aqi > 150 ? "Unhealthy" : "Good",
                          style: TextStyle(
                              fontSize: 20,
                              color: const Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Temperature: ${temperature.toStringAsFixed(1)}°C",
                    style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchAirQuality,
                    child: Text("Refresh"),
                  ),
                ],
              ),
      ),
    );
  }
}
