import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/features/levels/presentation/levels.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';

class CurrentLevelPage extends StatefulWidget {
  const CurrentLevelPage({super.key});

  @override
  State<CurrentLevelPage> createState() => _CurrentLevelPageState();
}

class _CurrentLevelPageState extends State<CurrentLevelPage> {
  int points = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPoints();
  }

  Future<void> fetchPoints() async {
    try {
      final data = await AuthServices().getUserProfile(context: context);

      setState(() {
        points = data?['points'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String getLevel(int p) {
    if (p >= 100) return "bin";
    if (p >= 50) return "general";
    return "rookie";
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final currentLevel = getLevel(points);

    int nextTarget;
    if (points < 50) {
      nextTarget = 50;
    } else if (points < 100) {
      nextTarget = 100;
    } else {
      nextTarget = 0;
    }

    final remaining = nextTarget == 0 ? 0 : (nextTarget - points);

    return Scaffold(
      appBar: const CustomAppBar(title: "Levels"),

      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  /// mathi ko points dekhaune box
                  Positioned(
                    top: 10,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPallete.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${user.name}'s Points",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$points",
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            remaining == 0
                                ? "Max Level Reached!"
                                : "$remaining points to next level",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// rookie
                  Positioned(
                    top: 180,
                    left: 20,
                    child: levelWidget(
                      "rookie",
                      "Fohor Rookie",
                      "assets/images/fohor_rookie.png",
                      currentLevel,
                      points,
                      0,
                    ),
                  ),

                  ///general
                  Positioned(
                    top: 340,
                    right: 20,
                    child: levelWidget(
                      "general",
                      "General Garbage",
                      "assets/images/general_garbage.png",
                      currentLevel,
                      points,
                      50,
                    ),
                  ),

                  /// bin
                  Positioned(
                    bottom: 120,
                    left: 20,
                    child: levelWidget(
                      "bin",
                      "Bin Bahadur",
                      "assets/images/binbahadur.png",
                      currentLevel,
                      points,
                      100,
                    ),
                  ),

                  ///button
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: CustomBigButton(
                      text: "Learn More",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LevelsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget levelWidget(
    String key,
    String name,
    String asset,
    String currentLevel,
    int points,
    int threshold,
  ) {
    final isActive = currentLevel == key;
    final isUnlocked = points >= threshold;

    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            ColorFiltered(
              colorFilter: isUnlocked
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.multiply,
                    )
                  : const ColorFilter.matrix([
                      //grey pareko image
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
              child: Image.asset(asset, height: 140, width: 140),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  "I'M HERE",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? AppPallete.backgroundColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
