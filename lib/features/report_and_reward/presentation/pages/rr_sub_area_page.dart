import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/area_list_tile.dart';
import 'package:binbahadhur/core/widgets/user_bottom_nav.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/features/report_and_reward/data/report_service.dart';
import 'package:binbahadhur/features/report_and_reward/presentation/pages/report_page.dart';

class RRSubAreaPage extends StatefulWidget {
  final String selectedArea;
  final List<String> subAreas;

  const RRSubAreaPage({
    super.key,
    required this.selectedArea,
    required this.subAreas,
  });

  @override
  State<RRSubAreaPage> createState() => _RRSubAreaPageState();
}

class _RRSubAreaPageState extends State<RRSubAreaPage> {
  String? selectedSubArea;
  int currentIndex = 0;
  bool isLoading = false;

  Future<void> proceedToReport() async {
    if (selectedSubArea == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a sub-area")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final reportId = await ReportService().createReport(
      context: context,
      area: widget.selectedArea,
      subArea: selectedSubArea!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (reportId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create report")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage(reportId: reportId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report and Reward",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF00872D),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: UserBottomNav(
        currentIndex: currentIndex,
        onIndexChanged: (index) {
          setState(() => currentIndex = index);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter by Area",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4D4D4D),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: widget.subAreas.length,
                itemBuilder: (context, index) {
                  final subArea = widget.subAreas[index];

                  return AreaListTile(
                    title: subArea,
                    isSelected: selectedSubArea == subArea,
                    onTap: () {
                      setState(() {
                        selectedSubArea = subArea;
                      });
                    },
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: CustomBigButton(
                text: isLoading ? "Loading..." : "Continue",
                onPressed: proceedToReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}