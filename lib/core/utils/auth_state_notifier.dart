import 'package:flutter/foundation.dart';

class AuthStateNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated() {
    if (_isAuthenticated == true) return;
    _isAuthenticated = true;
    notifyListeners();
  }

  void setUnauthenticated() {
    if (_isAuthenticated == false) return;
    _isAuthenticated = false;
    notifyListeners();
  }
}
