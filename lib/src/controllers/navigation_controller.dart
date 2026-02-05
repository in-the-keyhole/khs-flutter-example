import 'package:flutter/material.dart';

/// A class that manages navigation state for the app.
///
/// Controllers glue Data Services to Flutter Widgets. The NavigationController
/// manages which view is currently displayed.
class NavigationController with ChangeNotifier {
  NavigationController();

  int _currentIndex = 0;

  /// The current navigation index.
  int get currentIndex => _currentIndex;

  /// Navigate to a specific index.
  void navigateTo(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}
