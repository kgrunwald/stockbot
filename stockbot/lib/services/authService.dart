import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final ValueNotifier<bool> _authenticated = ValueNotifier<bool>(false);
  bool _authenticating = false;
  String _authError;

  AuthService();

  Future<bool> authenticateUser() async {
    if(!_authenticated.value && !_authenticating) {
      try {
        _authenticating = true;
        _authenticated.value = await _localAuth.authenticateWithBiometrics(
          localizedReason: "You must log in to see the settings page",
          useErrorDialogs: true,
          stickyAuth: false
        );
      } catch (e) {
        log("Exception in authentication: ${e.message}");
        _authError = e.message;
        _authenticated.value = false;
      }
    }

    _authenticating = false;
    return _authenticated.value;
  }

  ValueListenable<bool> get authenticatedListenable {
    return _authenticated;
  }

  String get authError {
    return _authError;
  }

  void logOut() {
    _authenticated.value = false;
  }
}