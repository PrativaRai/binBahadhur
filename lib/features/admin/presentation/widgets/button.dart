import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ButtonGroup extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ButtonGroup({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 60, color: AppPallete.backgroundColor),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppPallete.blackColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
