import 'package:flutter/material.dart';
import 'package:Stockbot/pages/accountDetails.dart';
import 'package:Stockbot/pages/home.dart';
import 'package:Stockbot/pages/settingsPage.dart';

class AppScaffold extends StatefulWidget {
  AppScaffold({Key key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  _AppScaffoldState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomAppBarColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), title: Text('Portfolio')),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text('Settings'))
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 72.0, left: 16, right: 16),
        child: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            HomePage(),
            AccountDetailsPage(),
            SettingsPage(),
          ],
        )
      )
    );
  }
}
