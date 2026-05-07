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
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUpUser() {
    authservices.signUpUser(
      context: context,
      phone: phoneController.text,
      password: passwordController.text,
      name: nameController.text,
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
                "Namaste\nHello there, please signup to continue!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.blackColor,
                ),
              ),
              const SizedBox(height: 25),
              AuthField(hintText: "Name", controller: nameController),
              const SizedBox(height: 15),
              AuthField(hintText: "Phone Number", controller: phoneController),
              const SizedBox(height: 15),
              AuthField(
                hintText: "Password",
                controller: passwordController,
                isObscureText: true,
              ),
              const SizedBox(height: 25),
              AuthButton(
                buttonText: 'Sign Up',
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    signUpUser();
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
