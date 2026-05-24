import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/features/user/presentation/pages/userNotificationScreen.dart';
import 'package:binbahadhur/features/user/presentation/pages/user_complain.dart';
import 'package:binbahadhur/features/user/presentation/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/area_page.dart';
import 'package:binbahadhur/features/report_and_reward/presentation/pages/rr_area_page.dart';
import 'package:provider/provider.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:binbahadhur/core/widgets/bottom_nav_bar.dart';
import 'package:binbahadhur/core/widgets/custom_option.dart';
import 'package:binbahadhur/features/levels/presentation/current_level.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int incomplete = 0;
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    try {
      final data = await AuthServices().getUserProfile(context: context);

      if (data == null) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        incomplete = data['tasksIncomplete'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final String name = user.name ?? "User";
    final String date = DateFormat('EEEE, d MMM').format(DateTime.now());
    String getLevel(int points) {
      if (points >= 100) return "bin";
      if (points >= 50) return "general";
      return "rookie";
    }

    String getLevelImage(int points) {
      if (points >= 100) return "assets/images/binbahadur.png";
      if (points >= 50) return "assets/images/general_garbage.png";
      return "assets/images/fohor_rookie.png";
    }

    return Scaffold(
      appBar: const CommonAppBar(title: "Home"),

      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            return; // already home
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserComplain()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CurrentLevelPage()),
            ).then((_) {
              fetchTasks();
            });
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            ).then((_) {
              fetchTasks();
            });
          }

          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserNotificationScreen(),
              ), // Changed from UserComplain()
            );
          }
        },
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppPallete.backgroundColor,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, $name!",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfilePage(),
                            ),
                          ).then((_) {
                            fetchTasks();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Image.asset(
                            "assets/images/fohor_rookie.png",
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.blackColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ServiceCard(
                        icon: Icons.schedule,
                        label: "Schedule Pickup",
                        onTap: () {
                          if (isLoading) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Loading...")),
                            );
                            return;
                          }

                          if (incomplete > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "You already have a pending task!",
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AreaPage(),
                            ),
                          ).then((_) {
                            fetchTasks();
                          });
                        },
                      ),

                      ServiceCard(
                        icon: Icons.card_giftcard,
                        label: "Report & Reward",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RRAreaPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
