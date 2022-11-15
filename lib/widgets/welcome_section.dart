import 'package:flutter/material.dart';

bool darkMode = false;

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.centerAlign,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool centerAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: color,
          ),
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              description,
              textAlign: centerAlign ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
