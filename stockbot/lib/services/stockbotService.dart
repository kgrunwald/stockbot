import 'dart:async';
import 'dart:developer';

import 'package:Stockbot/api/alpaca.dart';
import 'package:Stockbot/locator.dart';
import 'package:Stockbot/models/account.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/models/order.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/models/positionDetails.dart';
import 'package:Stockbot/services/storageService.dart';
import 'package:web_socket_channel/io.dart';

class StockbotService {
  AccountDetails accountDetails;
  StockPosition stockPosition;
  BondPosition bondPosition;
  PlanStatus status;
  PortfolioHistory history;
  IOWebSocketChannel channel;
  Bars bars;
  AlpacaApi api;
  Timer _timer;

  final StorageService storage = locator.get<StorageService>();
  String _apiKey = "";
  String _apiSecretKey = "";
  String _apiUrl = "https://paper-api.alpaca.markets";
  static const _StorageKeyAlpacaApiKey = "ALPACA_API_KEY";
  static const _StorageKeyAlpacaApiSecretKey = "ALPACA_API_SECRET_KEY";
  static const _StorageKeyAlpacaUrl = "ALPACA_API_URL";

  StockbotService() {
    accountDetails = locator.get<AccountDetails>();
    stockPosition = locator.get<StockPosition>();
    bondPosition = locator.get<BondPosition>();
    status = locator.get<PlanStatus>();
    history = locator.get<PortfolioHistory>();
    api = locator.get<AlpacaApi>();
    bars = locator.get<Bars>();
  }

  Future<void> setCredentials() async {
    _apiKey = await storage.read(_StorageKeyAlpacaApiKey);
    _apiSecretKey = await storage.read(_StorageKeyAlpacaApiSecretKey);
    _apiUrl = await storage.read(_StorageKeyAlpacaUrl);
    api.setCredentials(_apiKey, _apiSecretKey, _apiUrl);
  }

  Future<void> setApiKey(String key) async {
    await storage.write(_StorageKeyAlpacaApiKey, key);
    setCredentials();
  }

  Future<void> setApiSecretKey(String key) async {
    await storage.write(_StorageKeyAlpacaApiSecretKey, key);
    setCredentials();
  }

  Future<void> setApiUrl(String url) async {
    await storage.write(_StorageKeyAlpacaUrl, url);
    setCredentials();
  }

  String get apiKey => _apiKey;
  String get apiSecretKey => _apiSecretKey;
  String get apiUrl => _apiUrl;

  Future<void> start() async {
    await setCredentials();
    var futures = await Future.wait([
      api.fetchAccountDetails(),
      api.fetchStockPositionDetails("TQQQ"),
      api.fetchBondPositionDetails("AGG"),
      api.fetchBars("TQQQ", limit: 30),
      api.fetchBars("AGG", limit: 5),
      api.fetchOrders(),
      api.fetchPortfolioHistory(),
      willSkipNextSell()
    ]);

    AccountDetails details = futures[0];
    this.accountDetails.cashBalance = details.cashBalance;

    StockPosition stock = futures[1];
    this.stockPosition.symbol = stock.symbol;
    this.stockPosition.averageEntryPrice = stock.averageEntryPrice;
    this.stockPosition.costBasis = stock.costBasis;
    this.stockPosition.quantity = stock.quantity;
    this.stockPosition.currentPrice = stock.currentPrice;
    this.stockPosition.marketValue = stock.marketValue;
    this.stockPosition.unrealizedPL = stock.unrealizedPL;
    this.stockPosition.unrealizedPLPercent = stock.unrealizedPLPercent;
    this.stockPosition.unrealizedIntradayPL = stock.unrealizedIntradayPL;
    this.stockPosition.unrealizedIntradayPLPercent = stock.unrealizedIntradayPLPercent;

    BondPosition bond = futures[2];
    this.bondPosition.symbol = bond.symbol;
    this.bondPosition.averageEntryPrice = bond.averageEntryPrice;
    this.bondPosition.costBasis = bond.costBasis;
    this.bondPosition.quantity = bond.quantity;
    this.bondPosition.currentPrice = 100.0;
    this.bondPosition.marketValue = bond.marketValue;
    this.bondPosition.unrealizedPL = bond.unrealizedPL;
    this.bondPosition.unrealizedPLPercent = bond.unrealizedPLPercent;
    this.bondPosition.unrealizedIntradayPL = bond.unrealizedIntradayPL;
    this.bondPosition.unrealizedIntradayPLPercent = bond.unrealizedIntradayPLPercent;

    Bars tqqBars = futures[3];
    this.bars.bars = tqqBars.bars;

    double tqqWeekClose = tqqBars.bars[tqqBars.bars.length - 5].close;
    double tqqLastClose = tqqBars.bars[tqqBars.bars.length - 1].close;
    var tqqDiff = tqqLastClose - tqqWeekClose;
    this.stockPosition.lastWeekPLPercent = (tqqDiff) / tqqWeekClose;
    this.stockPosition.currentPrice = tqqBars.bars[tqqBars.bars.length - 1].close;

    Bars aggBars = futures[4];
    double aggWeekClose = aggBars.bars[0].close;
    double aggLastClose = aggBars.bars[aggBars.bars.length - 1].close;
    var aggDiff = aggLastClose - aggWeekClose;
    this.bondPosition.lastWeekPLPercent = (aggDiff) / aggWeekClose;
    this.bondPosition.currentPrice = aggBars.bars[aggBars.bars.length - 1].close;

    this.status.target = 20000 * 1.09;
    this.status.is30Down = false;

    List<Order> orders = futures[5];
    this.accountDetails.setOrders(orders);

    PortfolioHistory history = futures[6];
    this.history.baseValue = history.baseValue;
    this.history.equity = history.equity;
    this.history.profitLoss = history.profitLoss;
    this.history.profitLossPercent = history.profitLossPercent;
    this.history.timestamp = history.timestamp;

    this.status.is30Down = futures[7];

    await pollPositions(null);
    status.notify();
    details.notify();
    startPolling();
  }

  //  true  true  false        false        false
  //  buy   buy    sell (skip)  sell (skip) sell

  DateTime getPreviousActionDate(DateTime date) {
    if(date.month >= 10) {
      return DateTime(date.year, 10, 1);
    }
    
    if(date.month >= 7) {
      return DateTime(date.year, 7, 1);
    }

    if(date.month >= 4) {
      return DateTime(date.year, 4, 1);
    }

    return DateTime(date.year, 1, 1);
  }

  DateTime getPreviousQuarter(DateTime date) {
    if(date.month > 10) {
      return DateTime(date.year, 10, 1);
    }
    
    if(date.month > 7) {
      return DateTime(date.year, 7, 1);
    }

    if(date.month > 4) {
      return DateTime(date.year, 4, 1);
    }

    if(date.month > 1) {
      return DateTime(date.year, 1, 1);
    }

    return DateTime(date.year - 1, 10, 1);
  }

  Future<bool> willSkipNextSell() async {
    var now = DateTime.now();

    // Get last 4 years of bars
    var twoYearsAgo = DateTime(now.year - 2, now.month, now.day);
    var fourYearsAgo = DateTime(now.year - 4, now.month, now.day);
    var second = await this.api.fetchBars("TQQQ", start: twoYearsAgo, limit: 1000);
    var first = await this.api.fetchBars("TQQQ", start: fourYearsAgo, end: twoYearsAgo, limit: 1000);

    List<Bar> bars = [];
    List<Bar> tmp = [...first.bars, ...second.bars];
    for(var b in tmp) {
      var exists = false;
      for(var existing in bars) {
        if (existing.time == b.time) {
          exists = true;
          break;
        }
      }

      if(!exists) {
        bars.add(b);
        log("${b.time}");
      }
    }

    log("${bars.length} ${bars[0].time} ${bars[bars.length - 1].time}");

    List<DateTime> sells = [];
    List<DateTime> downs = [];

    DateTime init = getPreviousActionDate(now);
    List<DateTime> quarters = [init];
    // // Get last 2 years of quarters
    for(int i = 0; i < 8; i++) {
      quarters.add(getPreviousQuarter(quarters[quarters.length - 1]));
    }

    for(var date in quarters) {
      if(this.getQuarterAction(date, bars) == 'sell') {
        sells.add(date);
      }

      if(this.is30DownAtDate(date, bars)) {
        downs.add(date);
      }
    }

    // List<DateTime> sells = [];
    // for(int i = 0; i < actions.length; i++) {
    //   if (actions[i] == 'sell') {
    //     sells.add(quarters[i]);
    //   }
    // }


    log("$quarters");
    log("$sells");
    log("${downs.length}");
    // For each down 30, count the # of sell signals that follow
    // return # sells < # down 30
    return true;
  }

  String getQuarterAction(DateTime quarter, List<Bar> allBars) {
    var start = this.getPreviousQuarter(quarter);
    var endBar = this.getFirstBarBefore(quarter, allBars);
    var startBar = this.getFirstBarBefore(start, allBars);

    var startClose = startBar.close;
    var endClose = endBar.close;
    log("Getting action $start ${startBar.close} $quarter ${endBar.close}");
    if ((endClose / startClose) > 1.09) {
      return 'sell';
    }

    return 'buy';
  }

  Bar getFirstBarBefore(DateTime date, List<Bar> allBars) {
    for(int i = allBars.length - 1; i >= 0; i--) {
      Bar bar = allBars[i];
      if(bar.time.isBefore(date)) {
        return bar;
      }
    }
    return null;
  }

  bool is30DownAtDate(DateTime quarter, List<Bar> allBars) {
    var start = DateTime(quarter.year - 2, quarter.month, quarter.day);
    double lastClose = getFirstBarBefore(quarter, allBars).close;
    double high = 0;
    for(var b in allBars) {
      if(b.time.isAfter(start) && b.time.isBefore(quarter)) {
        if(b.close > high) {
          high = b.close;
          log("High: ${b.time} ${b.close}");
        }
      }
    }

    log("High between $start and $quarter is $high, close: $lastClose = ${high / lastClose}");
    return lastClose < (high * .7);
  }

  void startPolling() {
    this.stopPolling();
    _timer = Timer.periodic(Duration(seconds: 3), this.pollPositions);
  }

  void stopPolling() {
    if(_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  Future<void> pollPositions(Timer _) async {
    List<PositionDetails> positions = await api.fetchPositions();
    for(var position in positions) {
      if (position.symbol == "TQQQ") {
        this.stockPosition.marketValue = position.marketValue;
        this.stockPosition.currentPrice = position.currentPrice;
      } else if (position.symbol == "AGG") {
        this.bondPosition.marketValue = position.marketValue;
        this.bondPosition.currentPrice = position.currentPrice;
      }
    }
  }
}
