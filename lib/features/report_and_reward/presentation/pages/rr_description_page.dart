import 'dart:io';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/features/report_and_reward/data/report_service.dart';
import 'package:binbahadhur/features/report_and_reward/presentation/pages/rr_confirmation_page.dart';

class RRSaveDetailsPage extends StatefulWidget {
  //eta reportid pass garera ani tei id mai aru details thapna lai
  final File imageFile;
  final String reportId;

  const RRSaveDetailsPage({
    super.key,
    required this.imageFile,
    required this.reportId,
  });

  @override
  State<RRSaveDetailsPage> createState() => _RRSaveDetailsPageState();
}

class _RRSaveDetailsPageState extends State<RRSaveDetailsPage> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Description cannot be empty")),
      );
      return;
    }

    FocusScope.of(context).unfocus(); // fixes yellow flicker

    setState(() => isLoading = true);

    final updatedReport = await ReportService().updateReport(
      context: context,
      reportId: widget.reportId,
      description: controller.text,
      imageFile: widget.imageFile,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (updatedReport == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to submit report")));
      return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => RRConfirmationPage(report: updatedReport),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Report & Reward"),
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Snap Picture",
                  style: TextStyle(fontSize: 16, color: AppPallete.blackColor),
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    widget.imageFile,
                    height: 425,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Description",
                  style: TextStyle(fontSize: 16, color: AppPallete.blackColor),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(color: AppPallete.blackColor),
                  decoration: const InputDecoration(
                    hintText: "Write description...",
                    border: OutlineInputBorder(),
                    hintStyle: TextStyle(color: AppPallete.greyColor),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: CustomBigButton(
                    text: isLoading ? "Submitting..." : "Submit",
                    onPressed: isLoading
                        ? () {}
                        : () async => await submitReport(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
