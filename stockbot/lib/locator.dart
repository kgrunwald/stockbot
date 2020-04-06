import 'package:get_it/get_it.dart';
import 'package:stockbot/api/alpaca.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/models/bars.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/models/portfolioHistory.dart';
import 'package:stockbot/models/positionDetails.dart';
import 'package:stockbot/services/stockbotService.dart';
import 'package:stockbot/services/storageService.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<AlpacaApi>(AlpacaApi());
  locator.registerSingleton<PortfolioHistory>(PortfolioHistory.init());
  locator.registerSingleton<Bars>(Bars());
  locator.registerSingleton<StockPosition>(StockPosition());
  locator.registerSingleton<BondPosition>(BondPosition());
  locator.registerSingleton<StorageService>(StorageService());

  var stock = locator.get<StockPosition>();
  var bond = locator.get<BondPosition>();
  locator.registerSingleton<AccountDetails>(AccountDetails(stockPosition: stock, bondPosition: bond));

  var details = locator.get<AccountDetails>();
  locator.registerSingleton<PlanStatus>(PlanStatus(details, stock, bond));
  locator.registerSingleton<StockbotService>(StockbotService());
}