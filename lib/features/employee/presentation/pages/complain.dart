import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/employee/presentation/pages/employee.dart';
import 'package:binbahadhur/features/employee/presentation/pages/my_tasks_screen.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_textfield.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart';
import 'package:flutter/material.dart';

class Complain extends StatefulWidget {
  static const String routeName = '/Complain';
  const Complain({super.key});

  @override
  State<Complain> createState() => _ComplainState();
}

class _ComplainState extends State<Complain> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController employeeController = TextEditingController();

  // Instance of the service
  final EmployeeService employeeServices = EmployeeService();

  final _addComplainFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    descriptionController.dispose();
    employeeController.dispose();
    super.dispose();
  }

  void complain() async {
    if (_addComplainFormKey.currentState!.validate()) {
      final result = await employeeServices.addComplain(
        context: context,
        phoneNumber: phoneController.text,
        description: descriptionController.text,
        employee: employeeController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        showSnackBar(context, 'Complain added successfully');

        Navigator.pushNamedAndRemoveUntil(
          context,
          EmployeePage.routeName,
          (route) => false,
        );
      } else {
        showSnackBar(context, result['error'] ?? 'Failed to add complain');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Complain"),
      backgroundColor: AppPallete.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _addComplainFormKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomTextField(
                  controller: phoneController,
                  hintText: "Enter the User Phone Number",
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descriptionController,
                  hintText: "What is bothering you?",
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: employeeController,
                  hintText: "Your name",
                ),
                const SizedBox(height: 20),
                CustomButton(text: "Submit", onTap: complain),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
