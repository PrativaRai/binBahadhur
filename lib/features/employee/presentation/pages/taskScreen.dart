import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/pages/taskDetail.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Taskscreen extends StatefulWidget {
  const Taskscreen({super.key});

  @override
  State<Taskscreen> createState() => _TaskscreenState();
}

class _TaskscreenState extends State<Taskscreen> {
  final EmployeeService _service = EmployeeService();

  // Filter States
  String selectedDuration = "All";
  String selectedCity = "All";
  String selectedArea = "All";

  List<dynamic> allTasks = [];
  List<dynamic> filteredTasks = [];
  bool isLoading = true;
  String? errorMessage;

  // Pre-defined City and Sub-area configuration map
  final Map<String, List<String>> locationsMap = {
    "All": ["All"],
    "Dharan": ["All", "Bhanu Chowk", "Bijaypur"],
    "Biratnagar": ["All", "Traffic Chowk", "Mahendra Chowk"],
    "Itahari": ["All", "Bus Park", "Chatara Road"],
  };

  List<String> durationOptions = ["All", "Weekly", "Monthly", "Custom"];
  List<String> cityOptions = ["All", "Dharan", "Biratnagar", "Itahari"];
  List<String> areaOptions = ["All"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTasksFromServer();
    });
  }

  Future<void> loadTasksFromServer() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = context.read<UserProvider>().user.token;
    if (token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Not authenticated";
      });
      return;
    }

    final response = await _service.fetchAvailableTasks(token: token);

    if (mounted) {
      setState(() {
        isLoading = false;
        if (response['success'] == true) {
          allTasks = response['tasks'] ?? [];
          applyLocalFilters();
        } else {
          errorMessage = response['error'] ?? "Failed to fetch tasks";
        }
      });
    }
  }

  void applyLocalFilters() {
    setState(() {
      filteredTasks = allTasks.where((task) {
        bool matchesDuration =
            selectedDuration == "All" ||
            task['scheduleType'].toString().toLowerCase() ==
                selectedDuration.toLowerCase();

        bool matchesCity =
            selectedCity == "All" ||
            task['area'].toString().toLowerCase() == selectedCity.toLowerCase();

        bool matchesArea =
            selectedArea == "All" ||
            task['subArea'].toString().toLowerCase() ==
                selectedArea.toLowerCase();

        return matchesDuration && matchesCity && matchesArea;
      }).toList();
    });
  }

  void clearAllFilters() {
    setState(() {
      selectedDuration = "All";
      selectedCity = "All";
      selectedArea = "All";
      areaOptions = ["All"];
    });
    applyLocalFilters();
  }

  @override
  Widget build(BuildContext context) {
    bool hasActiveFilter =
        selectedDuration != "All" ||
        selectedCity != "All" ||
        selectedArea != "All";

    return Scaffold(
      appBar: const CommonAppBar(title: "Available Tasks"),
      backgroundColor: AppPallete.whiteColor,
      body: Column(
        children: [
          // Filter section strip
          buildFilterBar(hasActiveFilter),

          // Task Feed List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : filteredTasks.isEmpty
                ? const Center(
                    child: Text("No tasks match your selected filters"),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        color: AppPallete.whiteColor,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(
                            Icons.work,
                            color: AppPallete.backgroundColor,
                          ),
                          title: Text(
                            "${task['area']} - ${task['subArea']}",
                            style: const TextStyle(
                              color: AppPallete.blackColor,
                            ),
                          ),
                          subtitle: Text(
                            "Type: ${task['scheduleType']} | Status: ${task['status']}",
                            style: const TextStyle(
                              color: AppPallete.blackColor,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppPallete.backgroundColor,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(
                                  task: task,
                                  isReadOnly: true,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterBar(bool showClearButton) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (showClearButton)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                backgroundColor: Colors.red.shade50,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                avatar: Icon(
                  Icons.clear_all,
                  size: 16,
                  color: Colors.red.shade700,
                ),
                label: Text(
                  "Clear",
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: clearAllFilters,
              ),
            ),

          buildDropdownChip(
            label: "Duration",
            currentValue: selectedDuration,
            options: durationOptions,
            onChanged: (val) {
              setState(() => selectedDuration = val);
              applyLocalFilters();
            },
          ),
          buildDropdownChip(
            label: "City",
            currentValue: selectedCity,
            options: cityOptions,
            onChanged: (val) {
              setState(() {
                selectedCity = val;
                selectedArea = "All";
                areaOptions = locationsMap[val] ?? ["All"];
              });
              applyLocalFilters();
            },
          ),
          buildDropdownChip(
            label: "Area",
            currentValue: selectedArea,
            options: areaOptions,
            onChanged: (val) {
              setState(() => selectedArea = val);
              applyLocalFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget buildDropdownChip({
    required String label,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    bool isActive = currentValue != "All";
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: AppPallete.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 💡 Added offset positioning rule to prevent dropdown overlay over filter buttons
      offset: const Offset(0, 45),
      itemBuilder: (context) => options.map((opt) {
        bool isChecked = currentValue == opt;
        return PopupMenuItem<String>(
          value: opt,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                opt,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white70),
                child: Checkbox(
                  value: isChecked,
                  activeColor: AppPallete.whiteColor,
                  checkColor: AppPallete.backgroundColor,
                  onChanged: (bool? value) {
                    if (value == true) {
                      onChanged(opt);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppPallete.backgroundColor.withOpacity(0.12)
              : AppPallete.whiteColor,
          borderRadius: BorderRadius.circular(20),
          // 💡 Updated to thick green outline borders for clean contrast balance layouts
          border: Border.all(color: AppPallete.backgroundColor, width: 2.0),
        ),
        child: Row(
          children: [
            Text(
              "$label: $currentValue",
              style: TextStyle(
                color: isActive ? AppPallete.backgroundColor : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: isActive ? AppPallete.backgroundColor : Colors.black54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
