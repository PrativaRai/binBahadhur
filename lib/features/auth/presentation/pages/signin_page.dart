// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:binbahadhur/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';

import 'package:binbahadhur/core/theme/app_pallete.dart';

import 'package:binbahadhur/features/auth/presentation/widgets/auth_button.dart';
import 'package:binbahadhur/features/auth/presentation/widgets/auth_field.dart';

class SigninPage extends StatefulWidget {
  final VoidCallback onSignUpTap;
  const SigninPage({super.key, required this.onSignUpTap});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final AuthServices authservices = AuthServices();

  // Controllers - Updated to use phone
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signInUser() {
    authservices.signInUser(
      context: context,
      phone: phoneController.text,
      password: passwordController.text,
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
                "Namaste\nWelcome back, please enter your credentials to continue!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.blackColor,
                ),
              ),
              const SizedBox(height: 25),

              // Phone Field
              AuthField(hintText: "Phone Number", controller: phoneController),
              const SizedBox(height: 15),

              // Password Field
              AuthField(
                hintText: "Password",
                controller: passwordController,
                isObscureText: true,
              ),
              const SizedBox(height: 10),

              // Forgot Password Link
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppPallete.backgroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Sign In Button
              AuthButton(
                buttonText: 'Sign In',
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    signInUser();
                  }
                },
              ),

              const SizedBox(height: 20),

              // Toggle to Sign Up
              Center(
                child: GestureDetector(
                  onTap: widget.onSignUpTap,
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: const TextStyle(
                        color: AppPallete.blackColor,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
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
