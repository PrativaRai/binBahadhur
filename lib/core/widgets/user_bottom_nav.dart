import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/bottom_nav_bar.dart';
import 'package:binbahadhur/features/home/presentation/pages/home_page.dart';
import 'package:binbahadhur/features/user/presentation/pages/user_complain.dart';
import 'package:binbahadhur/features/levels/presentation/current_level.dart';
import 'package:binbahadhur/features/user/presentation/pages/userNotificationScreen.dart';
import 'package:binbahadhur/features/user/presentation/pages/user_profile_page.dart';

class UserBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const UserBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onIndexChanged(index);

        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserComplain()),
          );
        }
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CurrentLevelPage()),
          );
        }
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserNotificationScreen()),
          );
        }
        if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserProfilePage()),
          );
        }
      },
    );
  }
}