import 'package:get_it/get_it.dart';
import 'package:Stockbot/api/alpaca.dart';
import 'package:Stockbot/models/account.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/models/positionDetails.dart';
import 'package:Stockbot/services/stockbotService.dart';
import 'package:Stockbot/services/storageService.dart';

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
  locator.registerSingleton<AccountDetails>(
      AccountDetails(stockPosition: stock, bondPosition: bond));

  var details = locator.get<AccountDetails>();
  locator.registerSingleton<PlanStatus>(PlanStatus(details, stock, bond));
  locator.registerSingleton<StockbotService>(StockbotService());
}
