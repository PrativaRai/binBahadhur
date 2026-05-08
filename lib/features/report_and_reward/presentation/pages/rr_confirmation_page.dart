import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';

class RRConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const RRConfirmationPage({super.key, required this.report});

  String safe(String key) {
    return report[key]?.toString() ?? "-";
  }

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "http://192.168.18.109:3000";

    final imageUrl = report["imageUrl"];

    return Scaffold(
      appBar: const CustomAppBar(title: "Report Confirmation"),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Report Submitted Succesfully!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.blackColor,
                ),
              ),

              const SizedBox(height: 20),

              _tile("Report ID", safe("_id")),
              _tile("Area", safe("area")),
              _tile("Sub Area", safe("subArea")),
              _tile("Description", safe("description")),

              const SizedBox(height: 20),

              /// show image if exists
              if (imageUrl != null && imageUrl.toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl.toString().startsWith("http")
                        ? imageUrl
                        : "$baseUrl$imageUrl",
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Text("Image failed to load"),
                  ),
                )
              else
                const Text(
                  "No image uploaded",
                  style: TextStyle(color: Colors.grey),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: CustomBigButton(
                  text: "Go Home",
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppPallete.blackColor,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
