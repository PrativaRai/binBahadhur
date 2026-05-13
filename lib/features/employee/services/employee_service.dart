import 'dart:convert';
import 'package:binbahadhur/core/constants/global_variable.dart'; // Ensure 'uri' is defined here
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/Data/complain_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EmployeeService {
  final String baseUrl = uri;

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Ensure we always return a 'success' key if the backend doesn't
        if (decoded is Map<String, dynamic>) {
          return {...decoded, 'success': true};
        }
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'error':
              decoded['error'] ??
              decoded['msg'] ??
              'Server error: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to parse server response'};
    }
  }

  // 1. Fetch available tasks
  Future<Map<String, dynamic>> fetchAvailableTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/worker/available-tasks"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // 2. Accept task
  Future<Map<String, dynamic>> acceptTask(String taskId, String token) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/api/worker/accept-task/$taskId"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // 3. Fetch My Tasks
  Future<Map<String, dynamic>> fetchMyTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/worker/my-tasks"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // 4. Add Complaint
  Future<Map<String, dynamic>> addComplain({
    required BuildContext context,
    required String phoneNumber,
    required String description,
    required String employee,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      ComplainModel complain = ComplainModel(
        phoneNumber: phoneNumber,
        description: description,
        employee: employee,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/api/worker/add-complain'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: complain.toJson(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // 5. Create Schedule
  Future<Map<String, dynamic>> createSchedule({
    required String token,
    required String userId,
    required DateTime scheduleDate,
    required String description,
  }) async {
    try {
      // Validate MongoDB ObjectId format
      if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(userId)) {
        return {
          'success': false,
          'error': 'Invalid userId format. Must be a 24-character hex string.',
        };
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/schedule/create"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: json.encode({
          'userId': userId,
          'date': scheduleDate.toIso8601String(),
          'description': description,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  //start
  Future<Map<String, dynamic>> startTask(String taskId, String token) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/schedule/start/$taskId',
        ), // Match your router path
        headers: {
          'x-auth-token': token, // Use the same key as your middleware
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchActiveAndAvailableTasks(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/worker/active-tasks",
        ), // We will create this endpoint
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // 6. Complete Task (Finalize collection)
  Future<Map<String, dynamic>> completeTask({
    required String taskId,
    required String weight,
    required String money,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/worker/complete-task"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: json.encode({
          'taskId': taskId,
          'weightCollected': weight,
          'moneyPaid': money,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
