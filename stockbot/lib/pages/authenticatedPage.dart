import 'package:Stockbot/pages/loginPage.dart';
import 'package:Stockbot/services/authService.dart';
import 'package:flutter/material.dart';

class AuthenticatedPage extends StatelessWidget {
  final Widget child;
  final AuthService auth;

  AuthenticatedPage({@required this.child, @required this.auth});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (BuildContext context, bool authenticated, Widget child) {
        if(authenticated) {
          return child;
        }
        return LoginPage(this.auth);
      },
      valueListenable: this.auth.authenticatedListenable,
      child: child,
    );
  }
}