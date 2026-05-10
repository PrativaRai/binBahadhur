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

  bool isCodeSent = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  void sendVerificationCode() {
    if (phoneController.text.length == 10) {
      authServices.sendForgotPasswordOtp(
        context: context,
        phone: phoneController.text,
        onSuccess: () {
          setState(() {
            isCodeSent = true;
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit Nepali number")),
      );
    }
  }

  void handlePasswordUpdate() {
    if (formKey.currentState!.validate()) {
      authServices.resetPassword(
        context: context,
        phone: phoneController.text,
        otp: otpController.text,
        newPassword: newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
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
                Text(
                  isCodeSent
                      ? "Enter the code sent to your WhatsApp number."
                      : "Enter your registered phone number to receive a WhatsApp reset code.",
                  style: const TextStyle(
                    color: AppPallete.borderColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),

                AuthField(
                  hintText: "Phone Number",
                  controller: phoneController,
                  readOnly: isCodeSent,
                ),
                const SizedBox(height: 15),

                if (!isCodeSent)
                  AuthButton(
                    buttonText: "Send WhatsApp Code",
                    onTap: sendVerificationCode,
                  ),

                if (isCodeSent) ...[
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 20),

                  AuthField(
                    hintText: "6-digit WhatsApp OTP",
                    controller: otpController,
                  ),
                  const SizedBox(height: 15),

                  AuthField(
                    hintText: "New Password",
                    controller: newPasswordController,
                    isObscureText: true,
                  ),
                  const SizedBox(height: 25),

                  AuthButton(
                    buttonText: "Update Password",
                    onTap: handlePasswordUpdate,
                  ),

                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => isCodeSent = false),
                      child: const Text(
                        "Change Phone Number",
                        style: TextStyle(color: AppPallete.backgroundColor),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
