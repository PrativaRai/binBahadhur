import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/data/schedule_service.dart';

class SPConfirmationPage extends StatefulWidget {
  final String scheduleId;
  final String wasteType;
  final String description;
  final double pricePerKg;

  const SPConfirmationPage({
    super.key,
    required this.scheduleId,
    required this.wasteType,
    required this.description,
    required this.pricePerKg,
  });

  @override
  State<SPConfirmationPage> createState() => _SPConfirmationPageState();
}

class _SPConfirmationPageState extends State<SPConfirmationPage> {
  bool isLoading = true;
  Map<String, dynamic>? schedule;

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    final service = ScheduleService();

    final data = await service.getScheduleById(
      context: context,
      scheduleId: widget.scheduleId,
    );

    if (!mounted) return;

    setState(() {
      schedule = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (schedule == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load schedule")),
      );
    }
    String fixImageUrl(String? path) {
      if (path == null) return "";
      if (path.startsWith("http")) return path;
      return "http://192.168.18.109:3000$path";
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Confirmation"),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Schedule Created Successfully!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.blackColor,
                ),
              ),

              const SizedBox(height: 20),

              _info("Schedule ID", schedule!['_id']),
              _info("Area", schedule!['area']),
              _info("Sub Area", schedule!['subArea']),
              _info("Type", schedule!['scheduleType']),
              _info("Date", schedule!['scheduledDate'] ?? "N/A"),
              _info("Time", schedule!['scheduledTime'] ?? "N/A"),

              const SizedBox(height: 10),

              _info("Waste Type", schedule!['wasteType'] ?? widget.wasteType),
              _info(
                "Description",
                schedule!['description'] ?? widget.description,
              ),
              _info(
                "Price/kg",
                "Rs ${schedule!['pricePerKg'] ?? widget.pricePerKg}",
              ),
              if (schedule!['imageUrl'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fixImageUrl(schedule!['imageUrl']),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Text("Image failed to load"),
                    ),
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: CustomBigButton(
                  text: "Go to Home",
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

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 14, color: AppPallete.blackColor),
      ),
    );
  }
}
