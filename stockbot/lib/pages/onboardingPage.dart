import 'dart:developer';

import 'package:Stockbot/services/navigatorService.dart';
import 'package:flutter/material.dart';
import 'package:Stockbot/locator.dart';
import 'package:Stockbot/pages/settingsPage.dart';
import 'package:Stockbot/services/stockbotService.dart';

class OnboardingPage extends StatelessWidget {
  final StockbotService _service = locator.get<StockbotService>();
  final NavigationService _navigation = locator.get<NavigationService>();
  
  Future<bool> _checkReady(BuildContext context) async {
    // try {
      await _service.start();
      _navigation.navigateTo('/app');
      return true;
    // } catch (e) {
      // return false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).bottomAppBarColor,
        body: Padding(
            padding: const EdgeInsets.only(top: 72.0, left: 16, right: 16),
            child: FutureBuilder<bool>(
              future: _checkReady(context),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data) {
                    // navigate to homepage
                  } else {
                    return renderSettings(context);
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            )));
  }

  Widget renderSettings(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Enter Alpaca Credentials to get started.",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SettingsPage(),
        ),
        FlatButton(
            child: Text("Submit"),
            color: Theme.of(context).accentColor,
            onPressed: () async {
              _checkReady(context);
            })
      ],
    );
  }
}
