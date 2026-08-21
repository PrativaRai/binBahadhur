import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/widgets/auth_button.dart';
import 'package:binbahadhur/features/auth/presentation/widgets/auth_field.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback onSignInTap;
  const SignupPage({super.key, required this.onSignInTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthServices authservices = AuthServices();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  //Trigger the Node.js WhatsApp OTP
  void startWhatsappSignupFlow() {
    authservices.sendWhatsAppOTP(
      context: context,
      phone: phoneController.text,
      onSuccess: () {
        showOtpDialog();
      },
    );
  }

  //UI for WhatsApp OTP
  void showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.whiteColor,
        title: const Text(
          "WhatsApp Verification",
          style: TextStyle(
            color: AppPallete.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "We've sent a 6-digit code to your WhatsApp. Please enter it below.",
              style: TextStyle(color: AppPallete.blackColor),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: AppPallete.blackColor),
              decoration: InputDecoration(
                hintText: "Enter OTP",
                hintStyle: TextStyle(
                  color: AppPallete.blackColor.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              otpController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.backgroundColor,
            ),
            onPressed: () {
              // 3. Final Step: Verify WhatsApp OTP and save to MongoDB
              authservices.signUpWithWhatsApp(
                context: context,
                name: nameController.text,
                phone: phoneController.text,
                password: passwordController.text,
                otp: otpController.text,
              );
            },
            child: const Text(
              "Verify & Register",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Namaste\nJoin binBahadhur today!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.blackColor,
                ),
              ),
              const SizedBox(height: 25),
              AuthField(hintText: "Full Name", controller: nameController),
              const SizedBox(height: 15),
              AuthField(
                hintText: "Phone Number (e.g. 98XXXXXXXX)",
                controller: phoneController,
              ),
              const SizedBox(height: 15),
              AuthField(
                hintText: "Password",
                controller: passwordController,
                isObscureText: true,
              ),
              const SizedBox(height: 25),
              AuthButton(
                buttonText: 'Get OTP via WhatsApp',
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    startWhatsappSignupFlow();
                  }
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: widget.onSignInTap,
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                        color: AppPallete.blackColor,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppPallete.backgroundColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
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
