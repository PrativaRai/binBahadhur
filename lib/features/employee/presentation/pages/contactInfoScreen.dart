import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/custom_textfield.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart';

class ContactInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String taskId; // Ensure taskId is passed to this screen

  const ContactInfoScreen({
    super.key,
    required this.profile,
    required this.taskId,
  });

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  final TextEditingController moneyController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final EmployeeService _employeeService = EmployeeService();
  bool _isLoading = false;

  @override
  void dispose() {
    moneyController.dispose();
    weightController.dispose();
    super.dispose();
  }

  // --- BACKEND INTEGRATION LOGIC ---
  void _completeTask() async {
    final weight = weightController.text.trim();
    final money = moneyController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (weight.isEmpty || money.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in collection details")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calling the service method you created earlier
      final result = await _employeeService.completeTask(
        taskId: widget.taskId,
        weight: weight,
        money: money,
        token: userProvider.user.token!,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task finalized successfully!")),
          );
          // Navigate back to the main list and refresh
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? "Failed to complete task"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Customer Contact"),
      backgroundColor: AppPallete.whiteColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCustomerCard(),
                    const SizedBox(height: 25),
                    const Divider(thickness: 1),
                    const SizedBox(height: 15),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Collection Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: weightController,
                      hintText: "Enter Weight (in Kg)",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: moneyController,
                      hintText: "Enter Money Paid (Rs.)",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _completeTask,
                              child: const Text(
                                "COMPLETED",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Complain.routeName,
                                );
                              },
                              child: const Text(
                                "REPORT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white, size: 35),
            ),
            const SizedBox(height: 12),
            Text(
              widget.profile['name'] ?? 'N/A',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(Icons.phone, widget.profile['phone'] ?? 'N/A'),
            const SizedBox(height: 10),
            _infoRow(Icons.location_on, widget.profile['address'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppPallete.backgroundColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
