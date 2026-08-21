import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart';
import 'package:binbahadhur/features/employee/presentation/pages/contactInfoScreen.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = false;

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateValue);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateValue.toString();
    }
  }

  // --- LOGIC: START TASK & NAVIGATE ---
  Future<void> _handleStartTask() async {
    final token = context.read<UserProvider>().user.token;
    setState(() => _isLoading = true);

    try {
      final response = await _service.startTask(widget.task['_id'], token);

      if (response['success'] == true) {
        final rawProfile = response['task']['userId'];

        if (mounted) {
          if (rawProfile is Map<String, dynamic>) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactInfoScreen(
                  profile: rawProfile,
                  taskId: widget.task['_id'],
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Task started, but contact info unavailable."),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // LOGIC: ACCEPT TASK
  Future<void> _handleAcceptAction(String token) async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.acceptTask(widget.task['_id'], token);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Task accepted!"),
              backgroundColor: AppPallete.backgroundColor,
            ),
          );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<UserProvider>().user.token;

    String? existingPhone;
    if (widget.task['userId'] != null && widget.task['userId'] is Map) {
      existingPhone = widget.task['userId']['phone'];
    }

    final String? imageUrl = widget.task['imageUrl'];

    return Scaffold(
      appBar: const CommonAppBar(title: "Task Details"),
      backgroundColor: AppPallete.whiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              _buildImageCard(imageUrl),
              const SizedBox(height: 16),
            ],

            _buildInfoCard(
              title: "Schedule Type",
              icon: Icons.calendar_today,
              content: widget.task['scheduleType'] ?? 'N/A',
            ),
            _buildInfoCard(
              title: "Description",
              icon: Icons.description,
              content: widget.task['description'] ?? 'Not specified',
            ),
            _buildInfoCard(
              title: "Date & Time",
              icon: Icons.date_range,
              content:
                  "${_formatDate(widget.task['scheduledDate'])} ${widget.task['scheduledTime'] ?? ''}",
            ),
            _buildInfoCard(
              title: "Location",
              icon: Icons.location_on,
              content:
                  "Area: ${widget.task['area']}\nSub-Area: ${widget.task['subArea']}",
            ),
            _buildInfoCard(
              title: "Waste Type",
              icon: Icons.delete_outline,
              content: widget.task['wasteType'] ?? 'Not specified',
            ),
            if (widget.task['pricePerKg'] != null)
              _buildInfoCard(
                title: "Price per Kg",
                icon: Icons.attach_money,
                content: "Rs. ${widget.task['pricePerKg']}",
              ),
            if (existingPhone != null)
              _buildInfoCard(
                title: "Requester Phone",
                icon: Icons.phone,
                content: existingPhone,
              ),

            const SizedBox(height: 30),

            // BOTTOM ACTION BUTTONS
            if (!widget.isReadOnly) // 💡 Feed Screen -> Shows only ACCEPT
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => _handleAcceptAction(token),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ACCEPT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
            else // 💡 MyTasksScreen -> Shows START & REPORT
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
                        onPressed: _isLoading ? null : _handleStartTask,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "START",
                                style: TextStyle(
                                  color: Colors.white,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, Complain.routeName),
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
            style: const TextStyle(fontSize: 18, color: AppPallete.blackColor),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String url) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.blackColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    "Failed to load image",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          },
        ),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppPallete.blackColor,
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
