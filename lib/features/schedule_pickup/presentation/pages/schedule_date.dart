import 'package:binbahadhur/core/widgets/area_list_tile.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/data/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/widgets/custom_big_button.dart';
import 'package:binbahadhur/core/widgets/bottom_nav_bar.dart';
import 'package:binbahadhur/features/schedule_pickup/presentation/pages/schedule_page.dart';
// import 'package:binbahadhur/features/schedule_pickup/data/schedule_service.dart';

class ScheduleDatePage extends StatefulWidget {
  // receives area and sub-area from previous screen
  final String selectedArea;
  final String selectedSubArea;

  const ScheduleDatePage({
    super.key,
    required this.selectedArea,
    required this.selectedSubArea,
  });

  @override
  State<ScheduleDatePage> createState() => _ScheduleDatePageState();
}

class _ScheduleDatePageState extends State<ScheduleDatePage> {
  // stores which type user selected (Weekly, Monthly, Custom)
  String? selectedType;

  // stores current bottom nav index
  int currentIndex = 0;

  // list of schedule types to show
  final List<String> scheduleTypes = ['Weekly', 'Monthly', 'Custom'];

  // stores the date user picks (only for Custom)
  DateTime? selectedDate;

  // stores the time user picks (only for Custom)
  String? selectedTime;

  // available time options for dropdown
  final List<String> timeSlots = [
    '8 AM', '9 AM', '10 AM', '11 AM',
    '12 PM', '1 PM', '2 PM', '3 PM',
    '4 PM', '5 PM'
  ];

  // opens calendar popup for user to pick a date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // calendar opens on tomorrow by default
      initialDate: DateTime.now().add(const Duration(days: 1)),
      // user can't pick past dates
      firstDate: DateTime.now(),
      // user can only pick within 30 days
      lastDate: DateTime.now().add(const Duration(days: 30)),
      // make calendar green to match app theme
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00872D),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    // if user picked a date, save it
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // white top bar with green title
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

      // bottom navigation bar
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
            // label at top
            const Text(
              "Choose Type",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4D4D4D),
              ),
            ),

            const SizedBox(height: 16),

            // list of Weekly, Monthly, Custom
            Expanded(
              child: ListView.builder(
                itemCount: scheduleTypes.length,
                itemBuilder: (context, index) {
                  final type = scheduleTypes[index];
                  // reusing AreaListTile for each option
                  return AreaListTile(
                    title: type,
                    isSelected: selectedType == type,
                    onTap: () {
                      setState(() {
                        selectedType = type;
                      });
                    },
                  );
                },
              ),
            ),

            // show date and time picker only when Custom is selected
            if (selectedType == 'Custom') ...[
              const SizedBox(height: 16),

              // date label
              const Text(
                "Date",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF4D4D4D),
                ),
              ),

              const SizedBox(height: 8),

              // tap to open calendar
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      // shows selected date or placeholder
                      Text(
                        selectedDate == null
                            ? 'Select Date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // time label
              const Text(
                "Time",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF4D4D4D),
                ),
              ),

              const SizedBox(height: 8),

              // dropdown for time selection
              DropdownButtonFormField<String>(
                value: selectedTime,
                hint: const Text("Select Time"),
                items: timeSlots.map((time) {
                  return DropdownMenuItem(value: time, child: Text(time));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],

            // green continue button at bottom
            SizedBox(
              width: double.infinity,
              child: CustomBigButton(
                text: "Continue",
                                 
onPressed: () async {
  if (selectedType == null) return;
  
  // send data to server
  await ScheduleService().createSchedule(
    context: context,
    area: widget.selectedArea,
    subArea: widget.selectedSubArea,
    scheduleType: selectedType!,
    scheduledDate: selectedDate,
    scheduledTime: selectedTime,
  );

  // go to next screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SchedulePage(),
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