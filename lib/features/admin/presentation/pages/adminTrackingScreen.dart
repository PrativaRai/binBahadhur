import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/features/admin/data/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdminTrackingScreen extends StatefulWidget {
  const AdminTrackingScreen({super.key});

  @override
  State<AdminTrackingScreen> createState() => _AdminTrackingScreenState();
}

class _AdminTrackingScreenState extends State<AdminTrackingScreen> {
  final AdminServices _adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    // Use read instead of watch for the token inside build when passing to a Future
    final token = Provider.of<UserProvider>(context, listen: false).user.token;

    return Scaffold(
      appBar: CommonAppBar(title: "Tracking Panel"),
      backgroundColor: AppPallete.whiteColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _adminServices.fetchAllTasks(token),
        builder: (context, snapshot) {
          // Connection State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Exception/Network Error
          if (snapshot.hasError) {
            return Center(child: Text("Connection Error: ${snapshot.error}"));
          }

          //Backend reported success: false
          if (snapshot.data == null || snapshot.data!['success'] == false) {
            return Center(
              child: Text(snapshot.data?['error'] ?? "Failed to load tasks"),
            );
          }

          // 4. Extract List safely
          final List<dynamic> tasksList = snapshot.data!['tasks'] ?? [];

          if (tasksList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text("No active tasks found"),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasksList.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final task = tasksList[index];
              final customer = task['userId'];
              final employee = task['assignedTo'];
              final String status = task['status'] ?? 'pending';

              return Card(
                color: AppPallete.whiteColor,
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    "${task['area'] ?? 'N/A'} - ${task['subArea'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.blackColor,
                    ),
                  ),
                  trailing: _statusBadge(status),
                  children: [
                    const Divider(),
                    _infoRow(
                      title: "Customer",
                      name: customer?['name'] ?? "Unknown",
                      phone: customer?['phone'] ?? "N/A",
                      icon: Icons.person,
                      color: Colors.blue,
                    ),
                    _infoRow(
                      title: "Assigned To",
                      name: employee?['name'] ?? "Waiting for acceptance",
                      phone: employee?['phone'] ?? "",
                      icon: Icons.delivery_dining,
                      color: employee != null ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow({
    required String title,
    required String name,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      tileColor: AppPallete.whiteColor,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: AppPallete.blackColor),
      ),
      subtitle: Text(
        "$name\n$phone",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'completed') color = Colors.green;
    if (status == 'in-progress') color = Colors.blue;
    if (status == 'assigned') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
