import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/core/widgets/area_list_tile.dart';
import 'package:binbahadhur/core/widgets/bottom_nav_bar.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/sub_area_page.dart';

class AreaPage extends StatefulWidget {
  const AreaPage({super.key});

  @override
  State<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
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
          "Schedule Pickup",
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
      bottomNavigationBar: BottomNavBar(
         currentIndex: currentIndex,
         onTap: (index) {
         setState(() {
        currentIndex = index;
    });
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
              width : double.infinity,
              child: CustomBigButton(
                text: "Continue",
                onPressed: () {
                  if (selectedArea == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubAreaPage(
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