import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class sliderDevices extends StatelessWidget {
  final String smartDeviceName;
  final String iconPath;
  final bool powerOn;
  final Function(bool)? onChanged;

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
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: powerOn ? Colors.grey[900] : Color.fromARGB(44, 164, 167, 189),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // icon
              Image.asset(
                iconPath,
                height: 65,
                color: powerOn ? Colors.white : Colors.grey.shade700,
              ),

              // smart device name + slider
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        smartDeviceName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: powerOn ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Slider(
                    value: powerOn ? 1.0 : 0.0,
                    onChanged: (newValue) {
                      onChanged?.call(newValue >= 0.5);
                    },
                    min: 0.0,
                    max: 1.0,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
