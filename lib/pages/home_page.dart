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
  Timer? _pollingTimer;
  Timer? _sliderTimer;
  String weatherData = "Loading...";
  final String token = "NBFTcjxflna3kYS55nd5KLRAmcfDMUfi";
  final List<String> virtualPins = ['V1', 'V2', 'V3', 'V4', 'V6'];
  WebSocketChannel? channel;
  Timer? _timer;

  // list of smart devices
  List mySmartDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Red Light", "lib/icons/light-bulb.png", false, "V1"],
    ["White Light", "lib/icons/light-bulb.png", false, "V2"],
    ["Yellow Light", "lib/icons/light-bulb.png", false, "V3"],
    ["Smart Fan", "lib/icons/fan.png", false, "V4"],
  ];

  //for slider
  List mySliderDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Dimmer Light", "lib/icons/light-bulb.png", 0.0, "V6"],
  ];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    _startRepeatedFetching();
    startPolling();
    // fetchSliderValue();
    sliderPolling();
  }

  void startPolling() {
    _pollingTimer =
        Timer.periodic(Duration(seconds: 2), (_) => syncDeviceStates());
  }

  Future<void> syncDeviceStates() async {
    for (String pin in virtualPins) {
      String url = 'https://blynk.cloud/external/api/get?token=$token&$pin';
      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          if (pin == 'V6') {
            // Check if the pin is for the slider device
            double sliderValue = double.parse(response.body.trim());
            int sliderIndex =
                mySliderDevices.indexWhere((device) => device[3] == pin);
            if (sliderIndex != -1) {
              setState(() {
                mySliderDevices[sliderIndex][2] = sliderValue;
              });
            }
          } else {
            // For other devices (assumed boolean)
            bool isOn = response.body.trim() == '1';
            int deviceIndex =
                mySmartDevices.indexWhere((device) => device[3] == pin);
            if (deviceIndex != -1) {
              setState(() {
                mySmartDevices[deviceIndex][2] = isOn;
              });
            }
          }
        }
      } catch (e) {
        print("Error fetching state for pin $pin: $e");
      }
    }
  }

  //sync slider
  void sliderPolling() {
    _sliderTimer = Timer.periodic(Duration(seconds: 5), (_) => syncSlider());
  }

  Future<void> syncSlider() async {
    for (String pin in virtualPins) {
      String url = 'https://blynk.cloud/external/api/get?token=$token&$pin';
      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          double sliderValue = double.parse(response.body.trim());
          int deviceIndex =
              mySliderDevices.indexWhere((device) => device[3] == pin);
          if (deviceIndex != -1) {
            setState(() {
              mySliderDevices[deviceIndex][2] = sliderValue;
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

    String token = "NBFTcjxflna3kYS55nd5KLRAmcfDMUfi";
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

    String token = "NBFTcjxflna3kYS55nd5KLRAmcfDMUfi";
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
          'https://blynk.cloud/external/api/get?token=NBFTcjxflna3kYS55nd5KLRAmcfDMUfi&V7'));
      if (response.statusCode == 200) {
        final String responseBody = response.body.trim();
        // Check if the response body is a valid double
        if (double.tryParse(responseBody) != null) {
          final double data = double.parse(responseBody);
          setState(() {
            weatherData = data.toStringAsFixed(0); // No decimal places
          });
        } else {
          setState(() {
            weatherData = "Invalid data";
          });
        }
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

  void processMessage(dynamic message) {
    // Assuming 'message' is a JSON string with information about device states
    // Example message format: {"devicePin": "V1", "state": "1"}

    try {
      Map<String, dynamic> messageData = json.decode(message);
      String devicePin = messageData['devicePin'];
      bool isOn = messageData['state'] == "1";

      // Find the device in your list and update its state
      int deviceIndex =
          mySmartDevices.indexWhere((device) => device[3] == devicePin);
      if (deviceIndex != -1) {
        setState(() {
          mySmartDevices[deviceIndex][2] = isOn;
        });
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  }

  void sendMessage(String message) {
    if (channel != null) {
      channel!.sink.add(message);
    }
  }

  void disposeWebSocket() {
    if (channel != null) {
      channel!.sink.close();
      channel = null;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
                      double.tryParse(weatherData) != null
                          ? "${double.parse(weatherData).toStringAsFixed(0)} °C"
                          : weatherData, // Keep "Loading..." or any other non-double message
                      style: TextStyle(fontSize: 35, color: Colors.black),
                    ),

                    // AR icon
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(217, 37, 33, 33) // Replace with your desired background color
                      ),
                      child: InkWell(
                        onTap: () async {
                          await LaunchApp.openApp(
                            androidPackageName: 'com.DefaultCompany.switchAR',
                            openStore: true,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Adjust padding as needed
                          child: Image.asset(
                            'lib/icons/3.png', // Replace with your image asset path
                            width: 40.0, // Set the width as needed
                            height: 40.0, // Set the height as needed
                            // You can add color here if needed: color: Colors.white,
                          ),
                        ),
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  "Automation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              // Temperature Control
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: TemperatureControl(
                  token: "NBFTcjxflna3kYS55nd5KLRAmcfDMUfi",
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
