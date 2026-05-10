import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart.dart';
import 'package:flutter/material.dart';
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

  Future<void> _handleAcceptAction(String token) async {
    setState(() => _isAccepting = true);
    try {
      final response = await _service.acceptTask(widget.task['_id'], token);

      if (response['success'] == true && mounted) {
        // FIX: Extract keys directly from the backend 'task' object
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
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
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
                  Navigator.pop(context); // Close Dialog
                  Navigator.pop(context, true); // Return to list with success
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response['error'] ?? 'Accept failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<UserProvider>().user?.token;

    // Check if phone exists in the initial task data (e.g., if viewing 'My Tasks')
    String? existingPhone;
    if (widget.task['userId'] != null && widget.task['userId'] is Map) {
      existingPhone = widget.task['userId']['phone'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        backgroundColor: AppPallete.backgroundColor,
      ),
      backgroundColor: AppPallete.whiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: "Schedule Type",
              icon: Icons.calendar_today,
              content: widget.task['scheduleType'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Location",
              icon: Icons.location_on,
              content:
                  "Area: ${widget.task['area'] ?? 'N/A'}\nSub‑Area: ${widget.task['subArea'] ?? 'N/A'}",
            ),
            const SizedBox(height: 12),

            // Only show phone card if data is available
            if (existingPhone != null && existingPhone.isNotEmpty)
              _buildInfoCard(
                title: "Requester Phone",
                icon: Icons.phone,
                content: existingPhone,
              ),

            _buildInfoCard(
              title: "Waste Type",
              icon: Icons.delete_outline,
              content: widget.task['wasteType'] ?? 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Task ID",
              icon: Icons.fingerprint,
              content: widget.task['_id'] ?? 'Unknown',
            ),
            const SizedBox(height: 30),

            if (!widget.isReadOnly)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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
                          "ACCEPT THIS TASK",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods (_buildHeader, _buildInfoCard) remain same as your original code
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task['area'] ?? 'Unnamed Task',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.task['subArea'] ?? '',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
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
        border: Border.all(color: Colors.grey.shade300),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
