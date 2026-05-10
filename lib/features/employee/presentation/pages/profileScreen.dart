import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/customprofile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        // This calls the method we added to your AuthServices class
        future: authServices.getEmployeeProfile(context: context),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          // 2. Error State
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text("Failed to load profile data."),
                  TextButton(
                    onPressed: () => setState(() {}), // Refresh
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            );
          }

          //Data is ready
          final data = snapshot.data!;
          final String userRole =
              data['role']?.toString().toLowerCase() ?? 'user';
          final bool isEmployee = data['role'] == 'employee';

          return CustomProfile(
            name: snapshot.data!['name'] ?? 'Unknown',
            phone: snapshot.data!['phone'] ?? 'N/A',
            role: userRole,
            stats: isEmployee
                ? {
                    "Taken": snapshot.data!['tasksTaken'] ?? 0,
                    "Completed": snapshot.data!['tasksCompleted'] ?? 0,
                  }
                : null,
            actionButtons: [
              // Logout Button
              ElevatedButton(
                onPressed: () => authServices.logOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.backgroundColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Text("Log Out"),
              ),
            ],
          );
        },
      ),
    );
  }
}
