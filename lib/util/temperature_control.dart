import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    fetchCurrentTemperature();
  }

  Future<void> fetchCurrentTemperature() async {
    String getUrl = 'https://blynk.cloud/external/api/get?token=${widget.token}&${widget.pin}';
    try {
      var response = await http.get(Uri.parse(getUrl));
      if (response.statusCode == 200) {
        setState(() {
          currentTemperature = double.parse(response.body);
        });
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
        // Success response handling
        print("Temperature updated to $newTemperature");
      } else {
        // Error handling
        print("Failed to update temperature. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Network error handling
      print("Error updating temperature: $e");
    }
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