import 'package:binbahadhur/core/theme/app_pallete.dart';

import 'package:binbahadhur/features/employee/presentation/pages/profileScreen.dart';
import 'package:binbahadhur/features/employee/presentation/pages/taskScreen.dart';

import 'package:flutter/material.dart';
import 'package:binbahadhur/features/employee/presentation/pages/my_tasks_screen.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart'; // Ensure this import is correct

class EmployeePage extends StatefulWidget {
  static const String routeName = '/employee';
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const MyTasksScreen(),
    const Complain(),
    const Taskscreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body ma dynamically change garxa
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppPallete.blackColor,
        unselectedItemColor: AppPallete.greyColor,
        backgroundColor: AppPallete.backgroundColor,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Complain",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
