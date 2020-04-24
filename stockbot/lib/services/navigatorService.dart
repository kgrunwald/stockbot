import 'dart:developer';

import 'package:flutter/widgets.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
      
  Future<dynamic> navigateTo(String routeName, {dynamic arguments }) {
    return navigatorKey.currentState.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> push(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  bool pop() {
    return navigatorKey.currentState.pop();
  }
}