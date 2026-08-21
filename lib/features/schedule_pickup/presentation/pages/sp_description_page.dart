import 'dart:io';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/data/schedule_service.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/sp_confirmation_page.dart';

class SPSaveDetailsPage extends StatefulWidget {
  //eta scheduleid pass garera ani tei id mai aru details thapna lai
  final File imageFile;
  final String prediction;
  final String scheduleId;

  const SPSaveDetailsPage({
    super.key,
    required this.imageFile,
    required this.prediction,
    required this.scheduleId,
  });

  @override
  State<SPSaveDetailsPage> createState() => _SPSaveDetailsPageState();
}

class _SPSaveDetailsPageState extends State<SPSaveDetailsPage> {
  final TextEditingController controller = TextEditingController();

  final Map<String, double> pricePerKg = {
    "glass": 20,
    "metal": 100,
    "paper": 12,
    "plastic": 25,
  };
  final Map<String, List<String>> wasteDescriptions = {
    "plastic": [
      "Plastic Bottle",
      "Plastic Container",
      "Plastic Bag",
      "Plastic Packaging",
      "Other",
    ],

    "paper": ["Newspaper", "Cardboard", "Office Paper", "Magazine", "Other"],

    "glass": ["Glass Bottle", "Glass Jar", "Broken Glass", "Other"],

    "metal": ["Aluminum Can", "Steel Can", "Metal Scrap", "Other"],
  };

  bool isLoading = false;
  String? selectedDescription;

  late double pricePerKgValue;

  @override
  void initState() {
    super.initState();
    pricePerKgValue = pricePerKg[widget.prediction] ?? 0;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    String finalDescription = "";

    if (selectedDescription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a description")),
      );
      return;
    }

    if (selectedDescription == "Other") {
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

    setState(() => isLoading = true);

    final scheduleService = ScheduleService();

    final success = await scheduleService.updateSchedule(
      context: context,
      scheduleId: widget.scheduleId,
      wasteType: widget.prediction,
      description: finalDescription,
      pricePerKg: pricePerKgValue,
      imageFile: widget.imageFile,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SPConfirmationPage(
            scheduleId: widget.scheduleId,
            wasteType: widget.prediction,
            description: finalDescription,
            pricePerKg: pricePerKgValue,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Update failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Schedule and Pickup"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Snap Picture",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppPallete.blackColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      height: 300,
                      widget.imageFile,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    style: const TextStyle(color: AppPallete.blackColor),
                    readOnly: true,
                    controller: TextEditingController(text: widget.prediction),
                    decoration: const InputDecoration(
                      labelText: "Detected Type",
                      labelStyle: TextStyle(color: AppPallete.blackColor),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Price per kg: Rs ${pricePerKgValue.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.blackColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppPallete.blackColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedDescription,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: AppPallete.blackColor, // Green text
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: "Select Description",
                      labelStyle: TextStyle(color: AppPallete.blackColor),
                    ),
                    iconEnabledColor: AppPallete.blackColor, // Green icon
                    items:
                        wasteDescriptions[widget.prediction]
                            ?.map(
                              (description) => DropdownMenuItem<String>(
                                value: description,
                                child: Text(
                                  description,
                                  style: const TextStyle(
                                    color: AppPallete.blackColor, // Green text
                                  ),
                                ),
                              ),
                            )
                            .toList() ??
                        [],
                    onChanged: (value) {
                      setState(() {
                        selectedDescription = value;
                      });
                    },
                  ),

                  if (selectedDescription == "Other") ...[
                    const SizedBox(height: 16),

                    TextField(
                      style: const TextStyle(color: AppPallete.blackColor),
                      controller: controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Write description...",
                        hintStyle: TextStyle(color: AppPallete.blackColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: CustomBigButton(
                      text: isLoading ? "Submitting..." : "Submit",
                      onPressed: isLoading ? () {} : submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
