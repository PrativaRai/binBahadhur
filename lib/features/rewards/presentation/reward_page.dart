import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:provider/provider.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';

class RewardPage extends StatefulWidget {
  final int points; // Points from the single completed task

  const RewardPage({super.key, required this.points});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late String imagePath;
  late List<String> messages;
  late int userTotalPoints; // Added to keep track of the exact total

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String getLevel(int points) {
    if (points >= 100) return "bin";
    if (points >= 50) return "general";
    return "rookie";
  }

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userTotalPoints =
        userProvider.user.points; // Total points stored in provider
    final level = getLevel(userTotalPoints);

    if (level == "rookie") {
      imagePath = "assets/images/fohor_rookie.png";
      messages = [
        "You earned +${widget.points} points!",
        "Your total balance is now $userTotalPoints points.",
        "Reach 50 total points to unlock the next level!",
      ];
    } else if (level == "general") {
      imagePath = "assets/images/general_garbage.png";
      messages = [
        "Awesome! +${widget.points} points added.",
        "Total Balance: $userTotalPoints points.",
        "Bin Bahadur rank unlocks at 100 total points!",
      ];
    } else {
      imagePath = "assets/images/binbahadur.png";
      messages = [
        "+${widget.points} points claimed successfully!",
        "Total Balance: $userTotalPoints points.",
        "You are Bin Bahadur! Max level achieved!",
      ];
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void nextMessage() {
    if (currentIndex < messages.length - 1) {
      setState(() {
        currentIndex++;
      });
      _controller.forward(from: 0);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Rewards"),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// TEXT BUBBLE + FADE
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    messages[currentIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppPallete.blackColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// IMAGE SCALE ANIMATION
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(imagePath, height: 260),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: CustomBigButton(
                  text: currentIndex < messages.length - 1
                      ? "Continue"
                      : "Finish",
                  onPressed: nextMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
