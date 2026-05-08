import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/features/admin/presentation/pages/manage_employee.dart';
import 'package:binbahadhur/features/admin/presentation/pages/reports_pages.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/nav_bar.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  static const String routeName = '/Adminpage';
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int currentIndex = 0;

  // Grid Navigation Logic
  void navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, ReportsPage.routeName);
  }

  void navigateToManageEmployee(BuildContext context) {
    Navigator.pushNamed(context, ManageEmployee.routeName);
  }

  // Dynamic Navbar Items
  final List<NavItem> navItems = [
    NavItem(label: "Home", icon: Icons.home),
    NavItem(label: "Reports", icon: Icons.assignment_late),
    NavItem(label: "Suspend", icon: Icons.manage_accounts),
    NavItem(label: "Profile", icon: Icons.person),
  ];

  // Navbar Navigation Logic
  void onNavTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    // Link navbar items to pages
    if (index == 1) {
      Navigator.pushNamed(context, ReportsPage.routeName);
    } else if (index == 2) {
      Navigator.pushNamed(context, ManageEmployee.routeName);
    } else if (index == 3) {
      // TODO: Navigate to Admin Profile if you have one
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Admin Dashboard'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
      ),
      // Apply the same BottomNavBar here
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavTapped,
        items: navItems,
      ),
    );
  }
}
