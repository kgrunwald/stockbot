import 'package:Stockbot/lifecycleHandler.dart';
import 'package:Stockbot/pages/appScaffold.dart';
import 'package:Stockbot/pages/authenticatedPage.dart';
import 'package:Stockbot/pages/orderDetailsPage.dart';
import 'package:Stockbot/services/authService.dart';
import 'package:Stockbot/services/navigatorService.dart';
import 'package:Stockbot/services/stockbotService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/pages/onboardingPage.dart';
import 'package:Stockbot/models/account.dart';

import 'package:Stockbot/locator.dart';
import 'package:Stockbot/utils/colors.dart';
import 'models/positionDetails.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  var service = locator.get<StockbotService>();
  var auth = locator.get<AuthService>();
  var navigator = locator.get<NavigationService>();
  WidgetsBinding.instance.addObserver(LifecycleHandler(service, auth, navigator));
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
  final AuthService auth = locator.get<AuthService>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STOCKBOT',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: StockbotColors.Accent1,
        errorColor: StockbotColors.Error,
        accentColor: StockbotColors.Secondary,
        canvasColor: Color.fromRGBO(31, 31, 39, 1),
        bottomAppBarColor: Color.fromRGBO(20, 20, 22, 1),
        textTheme: GoogleFonts.robotoTextTheme().apply(bodyColor: Colors.white),
      ),
      navigatorKey: locator.get<NavigationService>().navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticatedPage(
          auth: this.auth,
          child: OnboardingPage()
        ),
        '/app': (context) => AuthenticatedPage(
          auth: this.auth,
          child: AppScaffold()
        ),
        '/order': (context) => AuthenticatedPage(
          auth: this.auth,
          child: OrderDetailsPage()
        ),
      },
    );
  }
}
