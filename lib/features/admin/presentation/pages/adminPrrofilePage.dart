import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/features/employee/presentation/widgets/customprofile.dart';
import 'package:binbahadhur/features/user/services/profile_service.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AuthServices authServices = AuthServices();
  final ProfileService profileService = ProfileService();

  Future<void> _pickAndUploadImage() async {
  final imageFile = await profileService.pickImage();
  if (imageFile == null) return;

  final imageUrl = await profileService.uploadProfilePic(
    context: context,
    imageFile: imageFile,
  );

  if (imageUrl != null) {
    setState(() {});
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: CommonAppBar(title: "Admin Profile"),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authServices.getEmployeeProfile(context: context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading profile"));
          }

          final data = snapshot.data!;

          return CustomProfile(
            name: data['name'] ?? 'Admin',
            phone: data['phone'] ?? 'N/A',
            role: data['role'] ?? 'admin',
            imageUrl: data['profilePic'],
            onCameraTap: _pickAndUploadImage,

            actionButtons: [
              ElevatedButton(
                onPressed: () => authServices.logOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.backgroundColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
