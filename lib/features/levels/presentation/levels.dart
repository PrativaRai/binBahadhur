import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Levels Info", showBackButton: true),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,

        child: Column(
          children: [
            _levelBox(
              image: "assets/images/fohor_rookie.png",
              title: "Fohor Rookie",
              kg: "Start your journey with 0 kg pickups",
              reverse: false,
            ),

            const SizedBox(height: 15),

            _levelBox(
              image: "assets/images/general_garbage.png",
              title: "General Garbage",
              kg: "50 kg Scheduled Pickups",
              reverse: true,
            ),

            const SizedBox(height: 15),

            _levelBox(
              image: "assets/images/binbahadur.png",
              title: "Binbahadur",
              kg: "100 kg Scheduled Pickups",
              reverse: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelBox({
    required String image,
    required String title,
    required String kg,
    required bool reverse,
  }) {
    final imageWidget = Image.asset(image, height: 160, width: 160);

    final textWidget = Expanded(
      child: Column(
        crossAxisAlignment: reverse
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: reverse ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppPallete.backgroundColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$kg",
            textAlign: reverse ? TextAlign.right : TextAlign.left,
            style: TextStyle(fontSize: 14, color: AppPallete.blackColor),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: reverse
            ? [textWidget, const SizedBox(width: 20), imageWidget]
            : [imageWidget, const SizedBox(width: 20), textWidget],
      ),
    );
  }
}
