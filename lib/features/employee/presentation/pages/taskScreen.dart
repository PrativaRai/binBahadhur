import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/pages/taskDetail.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart'; // fixed import (removed extra .dart)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Taskscreen extends StatefulWidget {
  const Taskscreen({super.key});

  @override
  State<Taskscreen> createState() => _TaskscreenState();
}

class _TaskscreenState extends State<Taskscreen> {
  final EmployeeService _service = EmployeeService();

  @override
  Widget build(BuildContext context) {
    final token = context.read<UserProvider>().user.token;

    if (token.isEmpty) {
      return const Scaffold(body: Center(child: Text("Not authenticated")));
    }

    return Scaffold(
      appBar: CommonAppBar(title: "Accepted Task"),
      backgroundColor: AppPallete.whiteColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _service.fetchMyTasks(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text("Error: ${snapshot.error ?? 'Unknown error'}"),
            );
          }

          final response = snapshot.data!;
          if (!response['success']) {
            return Center(
              child: Text("Failed to load tasks: ${response['error']}"),
            );
          }

          final tasks = response['tasks'] as List<dynamic>?;
          if (tasks == null || tasks.isEmpty) {
            return const Center(child: Text("No tasks assigned to you yet"));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                color: AppPallete.whiteColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.work,
                    color: AppPallete.backgroundColor,
                  ),
                  title: Text(
                    "${task['area']} - ${task['subArea']}",
                    style: TextStyle(color: AppPallete.blackColor),
                  ),
                  subtitle: Text(
                    "Type: ${task['scheduleType']} | Status: ${task['status']}",
                    style: TextStyle(color: AppPallete.blackColor),
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
                        builder: (_) =>
                            TaskDetailScreen(task: task, isReadOnly: true),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
