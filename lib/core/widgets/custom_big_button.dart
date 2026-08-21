import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
//continue button
class CustomBigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomBigButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0), 
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.backgroundColor,
          foregroundColor: Colors.white,
        ),
        child: Text(text),
      ),
    );
  }
}
