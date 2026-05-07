import 'dart:convert';
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/error/error_handling.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/Data/complain_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdminServices {
  // 1. FETCH ALL COMPLAINTS
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
          final List decodedBody = jsonDecode(res.body);
          for (int i = 0; i < decodedBody.length; i++) {
            complainList.add(ComplainModel.fromMap(decodedBody[i]));
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
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

  // 3. UPDATE USER STATUS (SUSPEND/BLOCK)
  void updateUserStatus({
    required BuildContext context,
    required String phoneNumber, // CHANGED: parameter name
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
}
