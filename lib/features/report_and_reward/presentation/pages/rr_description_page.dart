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
  final List<String> reportDescriptions = [
    "Overflowing Dustbin",
    "Illegal Waste Dumping",
    "Garbage Scattered on Road",
    "Uncollected Household Waste",
    "Blocked Drain with Waste",
    "Construction Waste",
    "Dead Animal",
    "Hazardous Waste",
    "Other (Specify)",
  ];
  bool isLoading = false;
  String? selectedDescription;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    String finalDescription = "";

    if (selectedDescription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a description")),
      );
      return;
    }

    if (selectedDescription == "Other (Specify)") {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Description cannot be empty")),
        );
        return;
      }

      finalDescription = controller.text.trim();
    } else {
      finalDescription = selectedDescription!;
    }

    FocusScope.of(context).unfocus();

    setState(() => isLoading = true);

    final updatedReport = await ReportService().updateReport(
      context: context,
      reportId: widget.reportId,
      description: finalDescription,
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

                DropdownButtonFormField<String>(
                  value: selectedDescription,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppPallete.blackColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Issue Type",
                    labelStyle: TextStyle(color: AppPallete.blackColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.blackColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppPallete.blackColor,
                        width: 2,
                      ),
                    ),
                  ),
                  iconEnabledColor: AppPallete.blackColor,
                  hint: const Text(
                    "Select Issue Type",
                    style: TextStyle(color: AppPallete.blackColor),
                  ),
                  items: reportDescriptions.map((description) {
                    return DropdownMenuItem<String>(
                      value: description,
                      child: Text(
                        description,
                        style: const TextStyle(color: AppPallete.blackColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDescription = value;
                    });
                  },
                ),

                if (selectedDescription == "Other (Specify)") ...[
                  const SizedBox(height: 16),

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
                ],

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
