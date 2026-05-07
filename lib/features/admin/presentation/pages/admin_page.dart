import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/admin/presentation/pages/manage_employee.dart';
import 'package:binbahadhur/features/admin/presentation/pages/reports_pages.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/button.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  static const String routeName = '/Adminpage';
  const AdminPage({super.key});

  // Navigation logic
  void navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, ReportsPage.routeName);
  }

  void navigateToManageEmployee(BuildContext context) {
    Navigator.pushNamed(context, ManageEmployee.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Admin Dashboard'),
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensure it fills the screen
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Wrap(
              spacing: 50, // Horizontal gap
              runSpacing: 30, // Vertical gap
              alignment: WrapAlignment.center,
              children: [
                // Reports Button
                ButtonGroup(
                  icon: Icons.assignment_late, // Icon for reports/complaints
                  label: "Reports",
                  onPressed: () => navigateToReports(context),
                ),

                // Manage Employee Button
                ButtonGroup(
                  icon: Icons.manage_accounts, // Icon for managing users
                  label: "Employee",
                  onPressed: () => navigateToManageEmployee(context),
                ),

                // Task Button
                ButtonGroup(
                  icon: Icons.add_task,
                  label: "Task",
                  onPressed: () {
                    // TODO: Implement task management logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
