import 'package:binbahadhur/features/auth/domain/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    phone: '',
    password: '',
    type: '',
    token: '',
    points: 0, // 1. Set initial points value to 0
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  // 2. Added explicit method to update points independently
  void updatePoints(int freshPoints) {
    _user = _user.copyWith(points: freshPoints);
    notifyListeners(); // <-- This triggers HomePage to swap out the badge assets immediately!
  }
}
