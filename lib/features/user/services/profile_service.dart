import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';

class ProfileService {
  final ImagePicker _picker = ImagePicker();

  // pick image from gallery
  Future<File?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // upload profile picture to server
  Future<String?> uploadProfilePic({
    required BuildContext context,
    required File imageFile,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$uri/api/upload-profile-pic'),
      );

      request.headers['x-auth-token'] = token;
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['profilePic'];
      } else {
        debugPrint("Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
}