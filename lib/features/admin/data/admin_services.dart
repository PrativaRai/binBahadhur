import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Internal imports - verify these match your project structure
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/error/error_handling.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/Data/complain_model.dart';

class AdminServices {
  // 1. FETCH ALL COMPLAINTS
  // Fetches the list of complaints and maps them to the ComplainModel
  Future<List<ComplainModel>> fetchAllComplain(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<ComplainModel> complainList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-complain'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (!context.mounted) return [];

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final Map<String, dynamic> decodedData = jsonDecode(res.body);
          final List<dynamic> complaintsData = decodedData['complaints'];

          for (int i = 0; i < complaintsData.length; i++) {
            complainList.add(
              ComplainModel.fromMap(complaintsData[i] as Map<String, dynamic>),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Fetch Error: ${e.toString()}");
      }
    }
    return complainList;
  }

  // 2. DELETE / RESOLVE COMPLAINT
  void deleteComplain({
    required BuildContext context,
    required ComplainModel complain,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/delete-complain'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': complain.id}),
      );

      if (!context.mounted) return;
      httpErrorHandle(response: res, context: context, onSuccess: onSuccess);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  // 3. UPDATE USER STATUS (SUSPEND/ACTIVATE)
  void updateUserStatus({
    required BuildContext context,
    required String phoneNumber,
    required String status,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/update-user-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'phoneNumber': phoneNumber, 'targetStatus': status}),
      );

      if (!context.mounted) return;
      httpErrorHandle(response: res, context: context, onSuccess: onSuccess);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  // 4. FETCH ALL TASKS (LIVE TRACKING)
  // Used by the Tracking Panel to see customers and assigned employees
  Future<Map<String, dynamic>> fetchAllTasks(String token) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/track-tasks'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(res.body);

      if (res.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      } else {
        return {
          'success': false,
          'tasks': [],
          'error': responseData['error'] ?? 'Failed to fetch tracking data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'tasks': [],
        'error': 'Network connection error: ${e.toString()}',
      };
    }
  }

  // 5. FETCH ALL BIN OVERFLOW REPORTS
  Future<List<dynamic>> fetchAllReports(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<dynamic> reportList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-reports'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (!context.mounted) return [];

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final Map<String, dynamic> decodedData = jsonDecode(res.body);
          reportList = decodedData['reports'];
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Fetch Error: ${e.toString()}");
      }
    }
    return reportList;
  }

  // 6. ACCEPT REPORT (GIVES USER +1 POINT)
  Future<void> acceptReport(BuildContext context, String reportId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final res = await http.post(
        Uri.parse('$uri/admin/accept-report'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'reportId': reportId}),
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Report accepted (+1 point)");
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  // 7. REJECT REPORT
  Future<void> rejectReport(BuildContext context, String reportId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final res = await http.post(
        Uri.parse('$uri/admin/reject-report'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'reportId': reportId}),
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Report rejected");
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }
}
