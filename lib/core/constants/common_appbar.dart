import 'package:flutter/material.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CommonAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      // Set the background color to your app pallete color
      backgroundColor: AppPallete.backgroundColor,
      // Remove the shadow so it blends with the scaffold body
      elevation: 0,
      // Ensure the text and icons are visible (e.g., white or black)
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        IconButton(
          onPressed: () => AuthServices().logOut(context),
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
