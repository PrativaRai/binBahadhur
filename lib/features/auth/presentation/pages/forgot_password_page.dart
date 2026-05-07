import 'package:flutter/material.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/widgets/auth_button.dart';
import 'package:binbahadhur/features/auth/presentation/widgets/auth_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthServices authServices = AuthServices();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppPallete.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Enter your phone number to receive a 6-digit verification code.",
                  style: TextStyle(color: AppPallete.borderColor),
                ),
                const SizedBox(height: 25),

                // Phone Input
                AuthField(
                  hintText: "Phone Number",
                  controller: phoneController,
                ),
                const SizedBox(height: 15),

                //send otp button
                AuthButton(
                  buttonText: "Send Verification Code",
                  onTap: () {
                    if (phoneController.text.length == 10) {
                      authServices.sendOtp(
                        context: context,
                        phone: phoneController.text,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter a valid 10-digit number"),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),

                // OTP Input
                AuthField(
                  hintText: "Enter 6-digit OTP",
                  controller: otpController,
                ),
                const SizedBox(height: 15),

                // New Password Input
                AuthField(
                  hintText: "New Password",
                  controller: newPasswordController,
                  isObscureText: true,
                ),
                const SizedBox(height: 25),

                // Update Button
                AuthButton(
                  buttonText: "Update Password",
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      authServices.resetPassword(
                        context: context,
                        phone: phoneController.text,
                        otp: otpController.text,
                        newPassword: newPasswordController.text,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
