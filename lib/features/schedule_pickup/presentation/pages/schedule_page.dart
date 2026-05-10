import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_option.dart';
import 'package:binbahadhur/features/trash_detection/presentation/pages/camera_page.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key, required this.scheduleId});
  final String scheduleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Schedule Pickup",
        showBackButton: true,
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            ServiceCard(
              icon: Icons.camera_alt,
              label: "Snap Picture",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPage(
                      mode: "schedule",
                      scheduleId: scheduleId,
                      reportId: "",
                    ), // reportId is not needed for schedule, passing empty string
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
