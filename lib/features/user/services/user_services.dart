import 'dart:convert';
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserService {
  Future<Map<String, dynamic>> addUserComplain({
    required BuildContext context,
    required String employeePhone,
    required String description,
    required String employeeName,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String token = userProvider.user.token;

      final http.Response res = await http.post(
        Uri.parse('$uri/api/user/report-employee'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'employeePhone': employeePhone,
          'description': description,
          'employeeName': employeeName,
        }),
      );

      // SAFETY CHECK: If the server sends HTML instead of JSON, capture it gracefully
      if (res.body.startsWith('<!DOCTYPE html>')) {
        return {
          'success': false,
          'error':
              'Server returned HTML instead of data. Check route URL or backend logs. (Status: ${res.statusCode})',
        };
      }

      final decodedResponse = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error':
              decodedResponse['error'] ??
              decodedResponse['msg'] ??
              'Server error',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
