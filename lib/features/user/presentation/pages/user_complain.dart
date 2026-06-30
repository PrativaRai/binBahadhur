import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_textfield.dart';
import 'package:binbahadhur/features/home/presentation/pages/home_page.dart';
import 'package:binbahadhur/core/widgets/user_bottom_nav.dart';

import 'package:binbahadhur/features/user/services/user_services.dart';

import 'package:flutter/material.dart';

class UserComplain extends StatefulWidget {
  static const String routeName = '/user-complain';
  const UserComplain({super.key});

  @override
  State<UserComplain> createState() => _UserComplainState();
}

class _UserComplainState extends State<UserComplain> {
  int currentIndex = 1; // complain tab

  // Capture targeted employee details
  final TextEditingController employeePhoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();

  final UserService userServices = UserService();
  final _addUserComplainFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    employeePhoneController.dispose();
    descriptionController.dispose();
    employeeNameController.dispose();
    super.dispose();
  }

  void submitComplain() async {
    if (_addUserComplainFormKey.currentState!.validate()) {
      final result = await userServices.addUserComplain(
        context: context,
        employeePhone: employeePhoneController.text, // Employee being reported
        description: descriptionController.text, // The issue description
        employeeName: employeeNameController.text, // Employee name
      );

      if (!mounted) return;

      if (result['success'] == true) {
        showSnackBar(context, 'Complaint submitted to Admin successfully');

        Navigator.pushNamedAndRemoveUntil(
          context,
          HomePage.routeName,
          (route) => false,
        );
      } else {
        showSnackBar(context, result['error'] ?? 'Failed to submit complaint');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Report an Employee"),
      backgroundColor: AppPallete.whiteColor,
      bottomNavigationBar: UserBottomNav(
        currentIndex: currentIndex,
        onIndexChanged: (index) {
          setState(() => currentIndex = index);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _addUserComplainFormKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomTextField(
                  controller: employeeNameController,
                  hintText: "Enter Employee Name",
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: employeePhoneController,
                  hintText: "Enter Employee Phone Number",
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descriptionController,
                  hintText: "Describe the issue with this employee...",
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Submit Complaint to Admin",
                  onTap: submitComplain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}