import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/pages/taskDetail.dart';
import 'package:binbahadhur/features/employee/services/employee_service.dart.dart'; // fixed import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final EmployeeService _service = EmployeeService();
  Future<Map<String, dynamic>>? _tasksFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tasksFuture == null) {
      final token = Provider.of<UserProvider>(
        context,
        listen: false,
      ).user?.token;
      if (token != null) {
        _tasksFuture = _service.fetchAvailableTasks(token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Jobs"),
        backgroundColor: AppPallete.backgroundColor,
      ),
      backgroundColor: AppPallete.whiteColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("No tasks currently available"));
          }

          final response = snapshot.data!;
          if (!response['success']) {
            return Center(child: Text("Error: ${response['error']}"));
          }

          final tasks = response['tasks'] as List<dynamic>?;
          if (tasks == null || tasks.isEmpty) {
            return const Center(child: Text("No tasks currently available"));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index] as Map<String, dynamic>;

              return Card(
                color: AppPallete.whiteColor,
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.assignment, color: Colors.green),
                  ),
                  title: Text(
                    "${task['area']} - ${task['subArea']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.blackColor,
                    ),
                  ),
                  subtitle: Text(
                    "Schedule: ${task['scheduleType']}",
                    style: const TextStyle(color: AppPallete.blackColor),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppPallete.backgroundColor,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: task),
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
