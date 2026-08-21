import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/error/error_handling.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/Data/complain_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EmployeeServices {
  void complain({
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

      http.Response res = await http.post(
        Uri.parse('$uri/api/worker/add-complain'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: complain.toJson(),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Complain added successfully');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
