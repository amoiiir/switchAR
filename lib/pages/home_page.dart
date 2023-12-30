import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../util/smart_device_box.dart';
import '../util/sliderDevices.dart';
import '../util/temperature_control.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for json decoding
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double horizontalPadding = 40;
  final double verticalPadding = 25;
  String weatherData = "Loading...";
  final String token = "3dZX49-NzPVihXqUUIMvYRPCQD-4jVK5";
  final List<String> virtualPins = ['V1', 'V2', 'V3', 'V4', 'V6'];
  Timer? _timer;

  // list of smart devices
  List mySmartDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Red Light", "lib/icons/light-bulb.png", false, "V1"],
    ["Main Light", "lib/icons/light-bulb.png", false, "V2"],
    ["Yellow Light", "lib/icons/light-bulb.png", false, "V3"],
    ["Smart Fan", "lib/icons/fan.png", false, "V4"],
  ];

  //for slider
  List mySliderDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Side Light", "lib/icons/light-bulb.png", 0.0, "V6"],
  ];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    _startRepeatedFetching();
  }

  Future<void> syncDeviceStates() async {
    for (String pin in virtualPins) {
      String url = 'https://blynk.cloud/external/api/get?token=$token&$pin';
      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          bool isOn = response.body.trim() == '1';
          int deviceIndex =
              mySmartDevices.indexWhere((device) => device[3] == pin);
          if (deviceIndex != -1) {
            setState(() {
              mySmartDevices[deviceIndex][2] = isOn;
            });
          }
        }
      } catch (e) {
        print("Error fetching state for pin $pin: $e");
      }
    }
  }

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });
  }

  //device power
  // Function to toggle device power and make API call
  void toggleDevicePower(int index, bool newState) async {
    setState(() {
      // mySmartDevices[index][2] = !mySmartDevices[index][2];
      mySmartDevices[index][2] = newState;
    });

    String token = "3dZX49-NzPVihXqUUIMvYRPCQD-4jVK5";
    String devicePin = mySmartDevices[index][3];
    int value = mySmartDevices[index][2] ? 1 : 0;

    String url =
        "https://blynk.cloud/external/api/update?token=$token&$devicePin=$value";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Handle successful response
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle network error
    }
  }

  //device power for slider
  // Function to toggle device power and make API call
  void toggleDeviceSlider(int index, double newState) async {
    setState(() {
      mySliderDevices[index][2] = newState;
    });

    String token = "3dZX49-NzPVihXqUUIMvYRPCQD-4jVK5";
    String devicePin = mySliderDevices[index][3];

    // Ensure the value is within 0 to 225 range
    int value = newState.round().clamp(0, 225);

    String url =
        "https://blynk.cloud/external/api/update?token=$token&$devicePin=$value";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Handle successful response
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle network error
    }
  }

  void _startRepeatedFetching() {
    // Set up a timer that calls fetchWeatherData every 2 seconds
    _timer =
        Timer.periodic(Duration(seconds: 2), (Timer t) => fetchWeatherData());
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://blynk.cloud/external/api/get?token=3dZX49-NzPVihXqUUIMvYRPCQD-4jVK5&V7'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          weatherData =
              data.toString(); // Adjust based on the API response format
        });
      } else {
        setState(() {
          weatherData = "Failed to fetch weather data";
        });
      }
    } catch (e) {
      setState(() {
        weatherData = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // menu icon
                    Text(
                      "$weatherData °C",
                      style:
                          TextStyle(fontSize: 25, color: Colors.grey.shade800),
                    ),

                    // account icon
                    IconButton(
                      color: Colors.grey[800],
                      onPressed: () async {
                        await LaunchApp.openApp(
                          androidPackageName: 'com.DefaultCompany.switchAR',
                          //if it installed, it will open, unless it will open playstore
                          openStore: true,
                        );
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 45.0, // Increase the size as per your requirement
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // welcome home
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Card(
                  elevation: 4, // Adjust elevation for desired shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius for desired roundness
                  ),
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(
                        30.0), // Adjust padding inside the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Home,",
                          style: TextStyle(
                              fontSize: 20, color: Colors.grey.shade800),
                        ),
                        Row(
                          children: [
                            Text(
                              'Haikal Wijdan',
                              style: GoogleFonts.bebasNeue(fontSize: 50),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Divider(
                  thickness: 1,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),
              ),

              const SizedBox(height: 25),

              // smart devices grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  "Smart Devices",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 2),

              // grid
              GridView.builder(
                shrinkWrap: true,
                itemCount: mySmartDevices.length,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.3,
                ),
                itemBuilder: (context, index) {
                  return SmartDeviceBox(
                    smartDeviceName: mySmartDevices[index][0],
                    iconPath: mySmartDevices[index][1],
                    powerOn: mySmartDevices[index][2],
                    onChanged: (bool value) {
                      toggleDevicePower(index, value);
                    },
                  );
                },
              ),

              // Add spacing between grids
              // const SizedBox(height: 20),

              // Second grid (Repeat the structure for the second grid)
              const SizedBox(height: 0),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    1, // Update this count as per your second grid's data
                padding: const EdgeInsets.symmetric(horizontal: 25),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.9 / 1,
                ),
                itemBuilder: (context, index) {
                  return sliderDevices(
                    smartDeviceName: mySliderDevices[index][0],
                    iconPath: mySliderDevices[index][1],
                    powerOn: mySliderDevices[index][2],
                    onChanged: (double value) {
                      toggleDeviceSlider(index, value);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              // Temperature Control
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: TemperatureControl(
                  token: "3dZX49-NzPVihXqUUIMvYRPCQD-4jVK5",
                  pin: "V8",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
