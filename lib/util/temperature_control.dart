import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // Import for using Timer

class TemperatureControl extends StatefulWidget {
  final String token;
  final String pin;

  const TemperatureControl({
    super.key,
    required this.token,
    required this.pin,
  });

  @override
  State<TemperatureControl> createState() => _TemperatureControlState();
}

class _TemperatureControlState extends State<TemperatureControl> {
  double currentTemperature = 0.0;
  Timer? _temperatureFetchTimer;

  @override
  void initState() {
    super.initState();
    fetchCurrentTemperature();
    _startRepeatedFetching();
  }

  void _startRepeatedFetching() {
    _temperatureFetchTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchCurrentTemperature());
  }

  Future<void> fetchCurrentTemperature() async {
    String getUrl = 'https://blynk.cloud/external/api/get?token=${widget.token}&${widget.pin}';
    try {
      var response = await http.get(Uri.parse(getUrl));
      if (response.statusCode == 200) {
        double fetchedTemperature = double.parse(response.body);
        if (fetchedTemperature != currentTemperature) {
          setState(() {
            currentTemperature = fetchedTemperature;
          });
        }
      }
    } catch (e) {
      print("Error fetching temperature: $e");
    }
  }

  void updateTemperature(double newTemperature) async {
    String updateUrl = 'https://blynk.cloud/external/api/update?token=${widget.token}&${widget.pin}=$newTemperature';
    try {
      final response = await http.get(Uri.parse(updateUrl));
      if (response.statusCode == 200) {
        print("Temperature updated to $newTemperature");
      } else {
        print("Failed to update temperature. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating temperature: $e");
    }
  }

  @override
  void dispose() {
    _temperatureFetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey[900],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature: ${currentTemperature.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        currentTemperature--;
                      });
                      updateTemperature(currentTemperature);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        currentTemperature++;
                      });
                      updateTemperature(currentTemperature);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}