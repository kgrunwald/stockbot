import 'dart:developer';

import 'package:Stockbot/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Stockbot/pages/accountDetails.dart';
import 'package:Stockbot/pages/home.dart';
import 'package:Stockbot/pages/settingsPage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:Stockbot/services/stockbotService.dart';

class PageScaffold extends StatefulWidget {
  PageScaffold({Key key}) : super(key: key);

  @override
  _PageScaffoldState createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> with TickerProviderStateMixin<PageScaffold>, WidgetsBindingObserver {
  final Widget body;
  int _currentIndex = 0;
  bool authenticated = false;

  _PageScaffoldState({this.body});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var service = locator.get<StockbotService>();
    if (state == AppLifecycleState.resumed) {
      service.startPolling();
    } else {
      service.stopPolling();
    }
  }

  Future<bool> authenticateUser() async {
    try {
      var localAuth = LocalAuthentication();
      return authenticated = await localAuth.authenticateWithBiometrics(
          localizedReason: "You must log in to see the settings page", stickyAuth: true);
    } on PlatformException catch (e) {
      log("Exception in authentication: ${e.message}");
      return authenticated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Theme.of(context).bottomAppBarColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (int index) async {
              if (index == 2) {
                if (!authenticated) {
                  var authSuccess = await authenticateUser();
                  log("Authenticated status: $authSuccess");
                  if (!authSuccess) {
                    return;
                  }
                }
              }

              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.trending_up), title: Text('Home')),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance), title: Text('Portfolio')),
              BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text('Settings'))
            ]),
        body: Padding(
            padding: const EdgeInsets.only(top: 72.0, left: 16, right: 16),
            child: IndexedStack(
              index: _currentIndex,
              children: <Widget>[
                HomePage(title: 'Stockbot'),
                AccountDetailsPage(),
                SettingsPage(),
              ],
            )));
  }
}
