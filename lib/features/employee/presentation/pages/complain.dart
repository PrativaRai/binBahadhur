import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/employee/Data/complain_services.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_textfield.dart';
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
  final EmployeeServices employeeServices = EmployeeServices();

  final _addComplainFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    employeeController.dispose();
  }

  void complain() {
    if (_addComplainFormKey.currentState!.validate()) {
      employeeServices.complain(
        context: context,
        phoneNumber: phoneController.text,
        description: descriptionController.text,
        employee: employeeController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Complain',
            style: TextStyle(color: AppPallete.whiteColor),
          ),
        ),
        backgroundColor: AppPallete.backgroundColor,
      ),
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
                  hintText: "Phone Number",
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
                  hintText: "Employee name/Id",
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
