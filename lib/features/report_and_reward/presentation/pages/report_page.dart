import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_option.dart';
import 'package:binbahadhur/features/trash_detection/presentation/pages/camera_page.dart';

class ReportPage extends StatelessWidget {
  final String reportId;
  const ReportPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Report & Reward",
        showBackButton: true,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,

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
                    builder: (_) => CameraPage(
                      mode: "report",
                      reportId: reportId,
                      scheduleId: null,
                    ),
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
