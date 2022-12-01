import 'package:flutter/material.dart';

class WeatherItem extends StatelessWidget {
  final int value;
  final String unit;
  final String imageUri;
  final String text;

  const WeatherItem({
    Key? key,required this.value,required this.unit,required this.imageUri,required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
             color: Colors.white,
            fontSize: 14.0,

          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Image.asset(
                  imageUri,
                ),
              ),
              const SizedBox(
                height: 8.0,

              ),
              Text(
                value.toString() + unit,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
