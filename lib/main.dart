import 'package:binbahadhur/core/theme/theme.dart';
import 'package:binbahadhur/features/admin/presentation/pages/admin_page.dart';
import 'package:binbahadhur/features/auth/presentation/pages/welcome_page.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:binbahadhur/features/employee/presentation/pages/employee.dart';
import 'package:binbahadhur/features/auth/data/auth_services.dart';
import 'package:binbahadhur/features/home/presentation/pages/home_page.dart';
import 'package:binbahadhur/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthServices authService = AuthServices();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'binBahadhur',
      theme: AppTheme.darkThemeMode,
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
      // home: AdminPage(),
      home: user.token.isEmpty ? const WelcomePage() : _getHome(user.type),
    );
  }

  Widget _getHome(String type) {
    switch (type) {
      case 'admin':
        return const AdminPage();
      case 'employee':
        return const EmployeePage();
      case 'user_provider':
        return const HomePage();
      case 'user':
      default:
        return const WelcomePage();
    }
  }
}
