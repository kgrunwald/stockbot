import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/pages/onboardingPage.dart';
import 'package:Stockbot/pages/pageScaffold.dart';
import 'package:Stockbot/models/account.dart';

import 'package:Stockbot/locator.dart';
import 'package:Stockbot/utils/colors.dart';
import 'models/positionDetails.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: locator.get<AccountDetails>()),
    ChangeNotifierProvider.value(value: locator.get<PlanStatus>()),
    ChangeNotifierProvider.value(value: locator.get<StockPosition>()),
    ChangeNotifierProvider.value(value: locator.get<BondPosition>()),
    ChangeNotifierProvider.value(value: locator.get<PortfolioHistory>()),
    ChangeNotifierProvider.value(value: locator.get<Bars>()),
  ], child: Stockbot()));
}

class Stockbot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STOCKBOT',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: StockbotColors.Accent1,
        errorColor: StockbotColors.Error,
        accentColor: StockbotColors.Secondary,
        canvasColor: Color.fromRGBO(39, 39, 47, 1),
        bottomAppBarColor: Color.fromRGBO(20, 20, 22, 1),
        textTheme: GoogleFonts.robotoTextTheme().apply(bodyColor: Colors.white),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingPage(),
        '/app': (context) => PageScaffold(),
      },
    );
  }
}
