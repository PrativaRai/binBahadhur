import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/customprofile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // app bar
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

      // body waits for data from server
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authServices.getUserProfile(context: context),
        builder: (context, snapshot) {
          // loading spinner while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // error state
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text("Failed to load profile data."),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            );
          }

          // data is ready
          final data = snapshot.data!;
          return CustomProfile(
            name: data['name'] ?? 'Unknown',
            phone: data['phone'] ?? 'N/A',
            role: 'user',
            stats: {
              "Previous": data['tasksDone'] ?? 0,
              "Current": data['tasksIncomplete'] ?? 0,
              "Points": data['points'] ?? 0,
            },
            actionButtons: [
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
