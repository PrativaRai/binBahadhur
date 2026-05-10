import 'dart:convert';
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeeService {
  final String baseUrl = 'http://10.0.2.2:3000';

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      return {
        'success': false,
        'error': decoded['error'] ?? 'Server error: ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    }
  }

  // Fetch available tasks
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

  //Accept task
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

  //Fetch My Tasks
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

  //Add Complaint
  static Future<Map<String, dynamic>> addComplain({
    required BuildContext context,
    required String token,
    required String phoneNumber,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$uri/api/worker/add-complain"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'description': description,
        }),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': body['msg'] ?? 'Failed to add complain',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createSchedule({
    required String token,
    required String userId,
    required DateTime scheduleDate,
    required String description,
  }) async {
    try {
      if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(userId)) {
        return {
          'success': false,
          'error':
              'Invalid userId format. Must be a 24-character hex string (MongoDB ObjectId).',
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
}
