import 'dart:async';
import 'dart:developer';

import 'package:Stockbot/services/authService.dart';
import 'package:Stockbot/utils/colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final AuthService auth;
  LoginPage(this.auth, {Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(this.auth);
}

class _LoginPageState extends State<LoginPage> {
  final AuthService auth;

  _LoginPageState(this.auth);

  @override
  void initState() {
    super.initState();
    this.auth.authenticateUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: StockbotColors.Secondary);
  }
}
