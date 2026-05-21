import 'package:binbahadhur/features/home/presentation/pages/home_page.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/schedule_date.dart';
import 'package:binbahadhur/features/user/presentation/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/core/widgets/area_list_tile.dart';
import 'package:binbahadhur/core/widgets/bottom_nav_bar.dart';

class SubAreaPage extends StatefulWidget {
  final String selectedArea;
  final List<String> subAreas;

  const SubAreaPage({
    super.key,
    required this.selectedArea,
    required this.subAreas,
  });

  @override
  State<SubAreaPage> createState() => _SubAreaPageState();
}

class _SubAreaPageState extends State<SubAreaPage> {
  String? selectedSubArea;
  int currentIndex = 0;
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
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserProfilePage(),
        ),
      );
    }
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
                text: "Continue",
                onPressed: () {
                  if (selectedSubArea == null) return;
                  Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder:(context)=>ScheduleDatePage(
                      selectedArea: widget.selectedArea, 
                      selectedSubArea: selectedSubArea!,)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}