import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/features/admin/data/admin_services.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class ManageEmployee extends StatefulWidget {
  static const String routeName = '/ManageEmployee';
  const ManageEmployee({super.key});

  @override
  State<ManageEmployee> createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  // CHANGED: Renamed controller from email to phone
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController employeeController = TextEditingController();
  final AdminServices adminServices = AdminServices();

  // Toggle variable: true = Suspend Mode, false = Lift Mode
  bool isSuspendMode = true;

  @override
  void dispose() {
    phoneController.dispose();
    descriptionController.dispose();
    employeeController.dispose();
    super.dispose();
  }

  void handleAccountStatus() {
    // CHANGED: Validation check for phone number
    if (phoneController.text.isEmpty) {
      showSnackBar(context, "Please enter a phone number.");
      return;
    }

    // Determine target status based on current mode
    String status = isSuspendMode ? 'suspended' : 'active';

    adminServices.updateUserStatus(
      context: context,
      // CHANGED: Passing phoneNumber instead of email
      phoneNumber: phoneController.text,
      status: status,
      onSuccess: () {
        showSnackBar(
          context,
          isSuspendMode
              ? "Account Suspended!"
              : "Suspension Lifted Successfully!",
        );
        phoneController.clear();
        descriptionController.clear();
        employeeController.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSuspendMode ? 'Suspend Employee' : 'Lift Suspension',
          style: const TextStyle(color: AppPallete.whiteColor),
        ),
        centerTitle: true,
        backgroundColor: isSuspendMode
            ? AppPallete.backgroundColor
            : Colors.green,
      ),
      backgroundColor: AppPallete.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              CustomTextField(
                controller: phoneController,
                // CHANGED: Hint text and keyboard type
                hintText: "Enter Phone Number",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // Reason
              if (isSuspendMode)
                CustomTextField(
                  controller: descriptionController,
                  hintText: "Reason for suspension",
                  maxLines: 3,
                ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: employeeController,
                hintText: "Employee Name",
              ),

              const SizedBox(height: 30),

              // The Button text changes based on the mode
              CustomButton(
                text: isSuspendMode ? "Suspend" : "Activate Account",
                onTap: handleAccountStatus,
              ),

              const SizedBox(height: 20),

              // Toggle Link
              TextButton(
                onPressed: () {
                  setState(() {
                    isSuspendMode = !isSuspendMode;
                  });
                },
                child: Text(
                  isSuspendMode
                      ? "Need to remove a suspension?"
                      : "Back to Suspend Page",
                  style: TextStyle(
                    color: isSuspendMode ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
