import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class EmployeePage extends StatefulWidget {
  static const String routeName = '/employee';

  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  int currentIndex = 0;

  // Function for the Grid Buttons
  void navigateToComplain(BuildContext context) {
    Navigator.pushNamed(context, Complain.routeName);
  }

  final List<NavItem> navItems = [
    NavItem(label: "Home", icon: Icons.home),
    NavItem(label: "Complain", icon: Icons.report),
    NavItem(label: "Tasks", icon: Icons.work),
    NavItem(label: "Profile", icon: Icons.person),
  ];

  // Logic for the Bottom Navigation Bar
  void onNavTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 1) {
      // Index 1 is "Complain" in your navItems list
      Navigator.pushNamed(context, Complain.routeName);
    }
    // Add other navigation logic for Profile or Tasks here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Employee Dashboard'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavTapped, // This now calls the navigation logic
        items: navItems,
      ),
    );
  }
}
