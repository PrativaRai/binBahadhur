import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/core/constants/global_variable.dart';

class ReportService {
  //yaa pani emulator ko lagi arkai uri halnuparchha hola

  final String uri =
      'http://192.168.18.110:3000'; //yo prativa le comment gareko hai emmulator ko lagi
  //final String uri = 'http://10.0.2.2:3000';

  // Create report and return reportId
  Future<String?> createReport({
    required BuildContext context,
    required String area,
    required String subArea,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final res = await http.post(
        Uri.parse('$uri/api/report'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'area': area, 'subArea': subArea}),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['report']['_id'];
      } else {
        debugPrint("Create report failed: ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Create report error: $e");
      return null;
    }
  }

  // Update report with image + description
  Future<Map<String, dynamic>?> updateReport({
    required BuildContext context,
    required String reportId,
    required String description,
    required File imageFile,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$uri/api/report/$reportId'),
      );

      // headers
      request.headers['x-auth-token'] = token;

      // text field
      request.fields['description'] = description;

      // file field (IMPORTANT NAME MUST MATCH BACKEND)
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['report'];
      } else {
        debugPrint("Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("updateReport error: $e");
      return null;
    }
  }

  // Fetch report by ID for confirmation page
  Future<Map<String, dynamic>?> getReportById({
    required BuildContext context,
    required String reportId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final res = await http.get(
        Uri.parse('$uri/api/report/$reportId'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['report'];
      } else {
        debugPrint("Fetch report failed: ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Fetch report error: $e");
      return null;
    }
  }
}
