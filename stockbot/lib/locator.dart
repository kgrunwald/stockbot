import 'package:get_it/get_it.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/models/positionDetails.dart';

final locator = GetIt.instance;

void setupLocator() {
  
  locator.registerSingleton<StockPosition>(StockPosition());
  locator.registerSingleton<BondPosition>(BondPosition());

  var stock = locator.get<StockPosition>();
  var bond = locator.get<BondPosition>();
  locator.registerSingleton<AccountDetails>(AccountDetails(stockPosition: stock, bondPosition: bond));

  var details = locator.get<AccountDetails>();
  locator.registerSingleton<PlanStatus>(PlanStatus(details, stock, bond));
}