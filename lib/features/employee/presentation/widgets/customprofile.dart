import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CustomProfile extends StatelessWidget {
  final String name;
  final String phone;
  final String role;
  final String? imageUrl;
  final Map<String, int>? stats;
  final List<Widget> actionButtons;
  final VoidCallback? onCameraTap;

  const CustomProfile({
    super.key,
    required this.name,
    required this.phone,
    required this.role,
    this.imageUrl,
    this.stats,
    required this.actionButtons,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          // --- Profile Header ---
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.withOpacity(0.1),
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.blue)
                    : null,
              ),
              GestureDetector(
                onTap: onCameraTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppPallete.blackColor,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: AppPallete.backgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          // --- Performance Stats (Conditional) ---
          if (stats != null) ...[
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats!.entries.map((entry) {
                  return Column(
                    children: [
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.blackColor,
                        ),
                      ),
                      Text(
                        entry.key,
                        style: const TextStyle(color: AppPallete.blackColor),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(
              Icons.phone_android,
              color: AppPallete.backgroundColor,
            ),
            title: const Text(
              "Phone Number",
              style: TextStyle(color: AppPallete.blackColor),
            ),
            subtitle: Text(
              phone,
              style: TextStyle(color: AppPallete.blackColor),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: actionButtons
                  .map(
                    (btn) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: btn,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}