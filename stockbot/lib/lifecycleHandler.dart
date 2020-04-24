import 'dart:async';
import 'dart:developer';

import 'package:Stockbot/services/authService.dart';
import 'package:Stockbot/services/navigatorService.dart';
import 'package:Stockbot/services/stockbotService.dart';
import 'package:flutter/material.dart';

class LifecycleHandler extends WidgetsBindingObserver {
  final StockbotService service;
  final AuthService auth;
  final NavigationService navigation;

  LifecycleHandler(this.service, this.auth, this.navigation);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed:
        auth.authenticateUser();
        service.startPolling();
        log("resumed");
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        auth.logOut();
        service.stopPolling();
        log("Logged out");
        break;
      case AppLifecycleState.paused:
        service.stopPolling();
        log("Stopped polling");
    }
  }
}