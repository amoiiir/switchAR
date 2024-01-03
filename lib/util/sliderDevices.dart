import 'package:flutter/material.dart';

class sliderDevices extends StatelessWidget {
  final String smartDeviceName;
  final String iconPath;
  final double powerOn; 
  final Function(double)? onChanged; 

  sliderDevices({
    super.key,
    required this.smartDeviceName,
    required this.iconPath,
    required this.powerOn, 
    required this.onChanged,
  });

   @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: powerOn > 0 ? Colors.grey[900] : Color.fromARGB(44, 164, 167, 189),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Light Dimmer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: powerOn > 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Slider(
                value: powerOn, // Use the slider value
                onChanged: onChanged, // Use onChanged directly
                min: 0.0,
                max: 225.0,
                inactiveColor: Colors.grey.shade700,
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}