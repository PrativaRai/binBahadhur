import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart';

import 'package:binbahadhur/features/employee/presentation/widgets/button.dart';
import 'package:flutter/material.dart';

class EmployeePage extends StatelessWidget {
  static const String routeName = '/employee';
  const EmployeePage({super.key});
  void navigatetoComplain(BuildContext context) {
    Navigator.pushNamed(context, Complain.routeName);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content to top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 50, // horizontal gap between items
              runSpacing: 30, // vertical gap when wrapped
              alignment: WrapAlignment.center,
              children: [
                // complain group
                ButtonGroup(
                  icon: Icons.report,
                  label: "Complain",
                  onPressed: () => navigatetoComplain(context),
                ),
                // verify
                ButtonGroup(
                  icon: Icons.verified,
                  label: "Verify",
                  onPressed: () {
                    // TODO: Add employee management logic
                  },
                ),
                // Task group
                ButtonGroup(
                  icon: Icons.star,
                  label: "Rating",
                  onPressed: () {
                    // TODO: Add task management logic
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
