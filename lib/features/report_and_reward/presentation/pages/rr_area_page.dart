import 'package:binbahadhur/features/report_and_reward/presentation/pages/rr_sub_area_page.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/core/widgets/area_list_tile.dart';
import 'package:binbahadhur/core/widgets/user_bottom_nav.dart';

class RRAreaPage extends StatefulWidget {
  const RRAreaPage({super.key});

  @override
  State<RRAreaPage> createState() => _RRAreaPageState();
}

class _RRAreaPageState extends State<RRAreaPage> {
  String? selectedArea;
  int currentIndex = 0;

  final Map<String, List<String>> areaData = {
    'Dharan': ['Bhanu Chowk', 'Bijaypur'],
    'Biratnagar': ['Traffic Chowk', 'Mahendra Chowk'],
    'Itahari': ['Bus Park', 'Chatara Road'],
  };

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
                itemCount: areaData.keys.length,
                itemBuilder: (context, index) {
                  final area = areaData.keys.elementAt(index);
                  return AreaListTile(
                    title: area,
                    isSelected: selectedArea == area,
                    onTap: () {
                      setState(() {
                        selectedArea = area;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomBigButton(
                text: "Continue",
                onPressed: () {
                  if (selectedArea == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RRSubAreaPage(
                        selectedArea: selectedArea!,
                        subAreas: areaData[selectedArea!]!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}