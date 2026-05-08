import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/core/widgets/custom_option.dart';

import 'package:binbahadhur/features/schedule_pickup/presentation/pages/area_page.dart';
import 'package:binbahadhur/features/report_and_reward/presentation/pages/rr_area_page.dart';
import 'package:provider/provider.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final String name = user.name ?? "User";
    final String date = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      appBar: const CommonAppBar(title: 'Home'),
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
                      Container(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              //maile schedulepage vanda agadi area schedule ma lagnu ko lagi AreaPage() ma link gareko instead of SchedulePage()
                              builder: (context) => const AreaPage(),
                            ),
                          );
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
