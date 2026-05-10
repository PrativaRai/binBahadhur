import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/Data/complain_services.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_button.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_textfield.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void complain() async {
    if (_addComplainFormKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Call the service
      final result = await EmployeeService.addComplain(
        context: context,
        token: userProvider.user.token,
        phoneNumber: phoneController.text,
        description: descriptionController.text,
      );

      // CRITICAL FIX: Check if widget is still in tree
      if (!mounted) return;

      if (result['success'] == true) {
        showSnackBar(context, 'Complain added successfully');
        Navigator.pop(context);
      } else {
        showSnackBar(context, result['error']);
      }
    }
  }

  // In the build method, delete the CustomTextField for "Employee name/Id"
  // The backend now handles this automatically via the token.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Complain"),
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
