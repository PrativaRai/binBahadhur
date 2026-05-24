import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';

class ScheduleService {
  //yo maile phone ma chalauna lai ho la emulator ko lagi arkai halnuparchha hola
  final String uri = 'http://192.168.18.110:3000';
  //final String uri = 'http://10.0.2.2:3000';

  // CREATE SCHEDULE
  Future<String?> createSchedule({
    required BuildContext context,
    required String area,
    required String subArea,
    required String scheduleType,
    DateTime? scheduledDate,
    String? scheduledTime,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final res = await http.post(
        Uri.parse('$uri/api/schedule'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'area': area,
          'subArea': subArea,
          'scheduleType': scheduleType,
          'scheduledDate': scheduledDate?.toIso8601String(),
          'scheduledTime': scheduledTime,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['schedule']?['_id'];
      }

      debugPrint("createSchedule failed: ${res.body}");
      return null;
    } catch (e) {
      debugPrint("createSchedule error: $e");
      return null;
    }
  }

  // UPDATE SCHEDULE image waste type description price per kg update garna milos vanera
  Future<bool> updateSchedule({
    required BuildContext context,
    required String scheduleId,
    required String wasteType,
    required String description,
    required double pricePerKg,
    required File imageFile,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$uri/api/schedule/$scheduleId'),
      );

      request.headers['x-auth-token'] = token;

      request.fields['wasteType'] = wasteType;
      request.fields['description'] = description;
      request.fields['pricePerKg'] = pricePerKg.toString();

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        return true;
      } else {
        debugPrint("updateSchedule failed: ${res.body}");
        return false;
      }
    } catch (e) {
      debugPrint("updateSchedule error: $e");
      return false;
    }
  }

  // GET BY ID confirmation page ma schedule ko details haru dekhauxa vanera
  Future<Map<String, dynamic>?> getScheduleById({
    required BuildContext context,
    required String scheduleId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final res = await http.get(
        Uri.parse('$uri/api/schedule/$scheduleId'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      debugPrint("getScheduleById failed: ${res.body}");
      return null;
    } catch (e) {
      debugPrint("getScheduleById error: $e");
      return null;
    }
  }
}
