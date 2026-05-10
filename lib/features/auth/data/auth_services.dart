import 'dart:convert';
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/core/error/error_handling.dart';
import 'package:binbahadhur/features/auth/presentation/pages/welcome_page.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/home/presentation/pages/home_page.dart';
import 'package:binbahadhur/features/admin/presentation/pages/admin_page.dart';
import 'package:binbahadhur/features/employee/presentation/pages/employee.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  //Send WhatsApp OTP (Signup)
  void sendWhatsAppOTP({
    required BuildContext context,
    required String phone,
    required VoidCallback onSuccess,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/send-otp'),
        body: jsonEncode({'phone': phone}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'OTP sent to your WhatsApp!');
          onSuccess();
        },
      );
    } catch (e) {
      if (context.mounted) showSnackBar(context, "Server Error: $e");
    }
  }

  //Final Sign Up
  void signUpWithWhatsApp({
    required BuildContext context,
    required String name,
    required String phone,
    required String password,
    required String otp,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'otp': otp,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Account Created! Please Login.');
          Navigator.pushNamedAndRemoveUntil(
            context,
            WelcomePage.routeName,
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  //Sign In User
  void signInUser({
    required BuildContext context,
    required String phone,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'phone': phone, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );

          userProvider.setUser(res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);

          if (!context.mounted) return;

          String nextRoute;
          if (userProvider.user.isAdmin) {
            nextRoute = AdminPage.routeName;
          } else if (userProvider.user.isEmployee) {
            nextRoute = EmployeePage.routeName;
          } else {
            nextRoute = HomePage.routeName;
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            nextRoute,
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  //Send Forgot Password OTP
  void sendForgotPasswordOtp({
    required BuildContext context,
    required String phone,
    required VoidCallback onSuccess,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/forgot-password'),
        body: jsonEncode({'phone': phone}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Reset OTP sent to WhatsApp!');
          onSuccess();
        },
      );
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  //Reset Password
  void resetPassword({
    required BuildContext context,
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/reset-password'),
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
          'newPassword': newPassword,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Password updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  //Get User Data (Auto-Login)
  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        prefs.setString('x-auth-token', '');
        return;
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (tokenRes.statusCode == 200) {
        var response = jsonDecode(tokenRes.body);
        if (response == true) {
          http.Response userRes = await http.get(
            Uri.parse('$uri/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token,
            },
          );

          if (!context.mounted) return;
          var userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(userRes.body);
        }
      }
    } catch (e) {
      debugPrint("Error in getUserData: $e");
    }
  }

  //Log Out
  void logOut(BuildContext context) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('x-auth-token', '');

      if (!context.mounted) return;
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.setUser(
        jsonEncode({
          'id': '',
          'name': '',
          'phone': '',
          'password': '',
          'type': '',
          'token': '',
        }),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        WelcomePage.routeName,
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  //Get Employee Profile Data
  Future<Map<String, dynamic>?> getEmployeeProfile({
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      // Get the current user ID from the provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String userId = userProvider.user.id;

      if (token == null || token.isEmpty) return null;

      http.Response res = await http.get(
        Uri.parse('$uri/api/profile/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      // Using your existing error handling logic
      Map<String, dynamic>? data;

      if (!context.mounted) return null;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          data = jsonDecode(res.body);
        },
      );

      return data;
    } catch (e) {
      if (context.mounted) showSnackBar(context, "Profile Error: $e");
      return null;
    }
  }
}
