import 'package:binbahadhur/features/auth/presentation/pages/signin_page.dart';
import 'package:binbahadhur/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';

class WelcomePage extends StatefulWidget {
  static const String routeName = '/Welcomepage';
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _imageAnimated = false;
  bool _textVisible = false;
  bool _slideUp = false;
  bool _isLogin = false; // Switch between login and signup

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Animation: Mascot appears
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() => _imageAnimated = true);
      }
    });

    // Animation: Text appears
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _textVisible = true);
      }
    });

    // Animation: Forms slide up
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _slideUp = true);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: Stack(
        children: [
          /// Mascot and Title Header
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _slideUp ? 40 : height / 2 - 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedScale(
                  duration: const Duration(seconds: 1),
                  scale: _imageAnimated ? 1 : 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      _imageAnimated ? 50 : 0,
                    ),
                    child: Image.asset(
                      'assets/binbahadhur.png',
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: _textVisible ? 1 : 0,
                  child: const Text(
                    "binBahadur",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Sliding Auth Container
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _slideUp ? 200 : height,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppPallete.whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              alignment: Alignment.topLeft,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isLogin
                    ? SigninPage(
                        onSignUpTap: () {
                          if (mounted) {
                            setState(() => _isLogin = false);
                          }
                        },
                      )
                    : SignupPage(
                        onSignInTap: () {
                          if (mounted) {
                            setState(() => _isLogin = true);
                          }
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
