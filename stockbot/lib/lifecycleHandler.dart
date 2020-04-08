import 'dart:developer';

import 'package:Stockbot/services/navigatorService.dart';
import 'package:Stockbot/services/stockbotService.dart';
import 'package:flutter/material.dart';

class LifecycleHandler extends WidgetsBindingObserver {
  final StockbotService service;
  final NavigationService navigation;

  LifecycleHandler(this.service, this.navigation);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      service.startPolling();
      log("resumed");
    } else {
      service.stopPolling();
      log("paused");
    }
  }
}