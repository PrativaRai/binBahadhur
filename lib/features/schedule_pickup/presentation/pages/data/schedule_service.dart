import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';

//ScheduleService handles all API calls for schedule pickup
class ScheduleService {
  // server URL
  String uri = 'http://10.0.2.2:3000';

  // create a new schedule pickup
  Future<void> createSchedule({
    required BuildContext context,
    required String area,
    required String subArea,
    required String scheduleType,
    DateTime? scheduledDate,
    String? scheduledTime,
  }) async {
    try {
      // get logged in user's token
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      // send data to server
      http.Response res = await http.post(
        Uri.parse('$uri/api/schedule'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'area': area,
          'subArea': subArea,
          'scheduleType': scheduleType,
          'scheduledDate': scheduledDate?.toIso8601String(),
          'scheduledTime': scheduledTime,
        }),
      );

      // check if successful
      if (res.statusCode == 200) {
        print('Schedule created successfully!');
      } else {
        print('Error: ${res.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}