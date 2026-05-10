import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isReadOnly;

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.isReadOnly = false,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final EmployeeService _service = EmployeeService();
  bool _isAccepting = false;

  // Helper to format date
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateValue);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateValue.toString();
    }
  }

  Future<void> _handleAcceptAction(String token) async {
    setState(() => _isAccepting = true);
    try {
      final response = await _service.acceptTask(widget.task['_id'], token);
      if (response['success'] == true && mounted) {
        /*
        final String creatorPhone =
            response['task']['creatorPhone']?.toString() ?? 'N/A';
        final String creatorName =
            response['task']['creatorName']?.toString() ?? 'User';

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Task Accepted"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You have accepted the task from $creatorName."),
                const SizedBox(height: 12),
                const Text("Contact the requester at:"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPallete.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: AppPallete.backgroundColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        creatorPhone,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
*/

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You have accepted this task"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['error'] ?? 'Accept failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppPallete.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  // Placeholder for Start action
  void _handleStartTask() {
    // TODO: Implement start task logic (e.g., update status to 'in-progress')
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Start task clicked - implement API call"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<UserProvider>().user?.token;

    // Check if phone exists in the initial task data
    String? existingPhone;
    if (widget.task['userId'] != null && widget.task['userId'] is Map) {
      existingPhone = widget.task['userId']['phone'];
    }

    return Scaffold(
      appBar: CommonAppBar(title: "Task Details"),
      backgroundColor: AppPallete.whiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // Schedule Type
            _buildInfoCard(
              title: "Schedule Type",
              icon: Icons.calendar_today,
              content: widget.task['scheduleType'] ?? 'N/A',
            ),
            const SizedBox(height: 12),

            // Scheduled Date & Time
            if (widget.task['scheduledDate'] != null ||
                widget.task['scheduledTime'] != null)
              _buildInfoCard(
                title: "Schedule Date & Time",
                icon: Icons.date_range,
                content:
                    "${_formatDate(widget.task['scheduledDate'])} ${widget.task['scheduledTime'] ?? ''}"
                        .trim(),
              ),
            const SizedBox(height: 12),

            // Location
            _buildInfoCard(
              title: "Location",
              icon: Icons.location_on,
              content:
                  "Area: ${widget.task['area'] ?? 'N/A'}\nSub‑Area: ${widget.task['subArea'] ?? 'N/A'}",
            ),
            const SizedBox(height: 12),

            // Waste Type
            _buildInfoCard(
              title: "Waste Type",
              icon: Icons.delete_outline,
              content: widget.task['wasteType'] ?? 'Not specified',
            ),
            const SizedBox(height: 12),

            // Price per Kg
            if (widget.task['pricePerKg'] != null)
              _buildInfoCard(
                title: "Price per Kg",
                icon: Icons.attach_money,
                content: "₹ ${widget.task['pricePerKg']}",
              ),
            const SizedBox(height: 12),

            // Description
            if (widget.task['description'] != null &&
                widget.task['description'].toString().isNotEmpty)
              _buildInfoCard(
                title: "Description",
                icon: Icons.description,
                content: widget.task['description'],
              ),
            const SizedBox(height: 12),

            _buildInfoCard(
              title: "Task Id",
              icon: Icons.description,
              content: widget.task['_id'] ?? "Unknown",
            ),
            // Requester Phone (if available)
            if (existingPhone != null && existingPhone.isNotEmpty)
              _buildInfoCard(
                title: "Requester Phone",
                icon: Icons.phone,
                content: existingPhone,
              ),

            const SizedBox(height: 30),

            //ACCEPT for available tasks, START + REPORT for assigned tasks
            if (!widget.isReadOnly)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.backgroundColor,
                    foregroundColor: AppPallete.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: token == null || _isAccepting
                      ? null
                      : () => _handleAcceptAction(token),
                  child: _isAccepting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ACCEPT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

            if (widget.isReadOnly)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _handleStartTask,
                        child: const Text(
                          "START",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, Complain.routeName);
                        },
                        child: const Text(
                          "REPORT",
                          style: TextStyle(
                            fontSize: 16,
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 246, 225),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPallete.blackColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task['area'] ?? 'Unnamed Task',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppPallete.blackColor,
            ),
          ),
          Text(
            widget.task['subArea'] ?? '',
            style: TextStyle(fontSize: 18, color: AppPallete.blackColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.blackColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Colors.green.shade700),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppPallete.blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: AppPallete.blackColor),
          ),
        ],
      ),
    );
  }
}
