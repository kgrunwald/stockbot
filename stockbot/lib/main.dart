import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/pages/pageScaffold.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/services/stockbotService.dart';

import 'package:stockbot/locator.dart';
import 'models/positionDetails.dart';

void main() async {
  setupLocator();
  var svc = StockbotService();
  await svc.start();
  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: locator.get<AccountDetails>()),
      ChangeNotifierProvider.value(value: locator.get<PlanStatus>()),
      ChangeNotifierProvider.value(value: locator.get<StockPosition>()),
      ChangeNotifierProvider.value(value: locator.get<BondPosition>()),
    ],
    child: Stockbot()
  ));
}

class Stockbot extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STOCKBOT',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(39, 39, 47, 1),
        errorColor: Color.fromRGBO(252, 105, 94, 1),
        accentColor: Color.fromRGBO(43, 184, 129, 1),
        canvasColor: Color.fromRGBO(51, 51, 61, 1),
        bottomAppBarColor: Color.fromRGBO(39, 39, 47, 1),
        textTheme: GoogleFonts.robotoTextTheme().apply(
          bodyColor: Colors.white
        ),
      ),
      home: PageScaffold(),
    );
  }
}

