import 'package:binbahadhur/features/admin/presentation/pages/admin_page.dart';
import 'package:binbahadhur/features/admin/presentation/pages/manage_employee.dart';
import 'package:binbahadhur/features/admin/presentation/pages/reports_pages.dart';
import 'package:binbahadhur/features/employee/presentation/pages/complain.dart';
import 'package:binbahadhur/features/employee/presentation/pages/employee.dart';
import 'package:binbahadhur/features/employee/presentation/pages/my_tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/features/home/presentation/pages/home_page.dart';
import 'package:binbahadhur/features/auth/presentation/pages/welcome_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const WelcomePage(),
        );

      //homepage ma janxa
      case HomePage.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const HomePage(),
        );

      //admin
      case AdminPage.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const AdminPage(),
        );

      //employee
      case EmployeePage.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const EmployeePage(),
        );

      //mytaskscreen
      case MyTasksScreen.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const MyTasksScreen(),
        );

      //welcome
      case WelcomePage.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const WelcomePage(),
        );

      //complain
      case Complain.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Complain(),
        );

      //report

      case ReportsPage.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ReportsPage(),
        );

      //manageemployee admin  ko

      case ManageEmployee.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageEmployee(),
        );
      default:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
