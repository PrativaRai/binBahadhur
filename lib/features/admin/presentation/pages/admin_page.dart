import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/admin/presentation/pages/adminPrrofilePage.dart';
import 'package:binbahadhur/features/admin/presentation/pages/adminTrackingScreen.dart';
import 'package:binbahadhur/features/admin/presentation/pages/manage_employee.dart';
import 'package:binbahadhur/features/admin/presentation/pages/reports_pages.dart';

import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  static const String routeName = '/Adminpage';
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const AdminTrackingScreen(),
    const ReportsPage(),
    const ManageEmployee(),
    const AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      body: IndexedStack(index: currentIndex, children: pages),

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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Manage",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
