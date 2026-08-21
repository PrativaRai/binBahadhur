import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: color ?? AppPallete.backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == null ? AppPallete.whiteColor : AppPallete.blackColor,
        ),
      ),
    );
  }
}
