import 'dart:async';
import 'dart:convert';
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

  final StorageService storage = locator.get<StorageService>();
  String _apiKey = "";
  String _apiSecretKey = "";
  static const _StorageKeyAlpacaApiKey = "ALPACA_API_KEY";
  static const _StorageKeyAlpacaApiSecretKey = "ALPACA_API_SECRET_KEY";

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
    api.setCredentials(_apiKey, _apiSecretKey);
  }

  Future<void> setApiKey(String key) async {
    await storage.write(_StorageKeyAlpacaApiKey, key);
    setCredentials();
  }

  Future<void> setApiSecretKey(String key) async {
    await storage.write(_StorageKeyAlpacaApiSecretKey, key);
    setCredentials();
  }

  String get apiKey => _apiKey;
  String get apiSecretKey => _apiSecretKey;

  Future<void> start() async {
    await setCredentials();
    var futures = await Future.wait([
      api.fetchAccountDetails(),
      api.fetchStockPositionDetails("TQQQ"),
      api.fetchBondPositionDetails("AGG"),
      api.fetchBars("TQQQ", limit: 14),
      api.fetchBars("AGG", limit: 10),
      api.fetchOrders(),
      api.fetchPortfolioHistory()
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

    double tqqWeekClose = 0;
    double tqqLastClose = 0;
    for (var bar in tqqBars.bars) {
      if (bar.time.toUtc().weekday == DateTime.friday) {
        if (tqqWeekClose == 0 && tqqLastClose == 0) {
          tqqWeekClose = bar.close;
        } else if (tqqLastClose == 0) {
          tqqLastClose = bar.close;
        } else {
          tqqWeekClose = tqqLastClose;
          tqqLastClose = bar.close;
        }
      }
    }
    var tqqDiff = tqqLastClose - tqqWeekClose;
    this.stockPosition.lastWeekPLPercent = (tqqDiff) / tqqWeekClose;
    this.stockPosition.currentPrice = tqqBars.bars[tqqBars.bars.length - 1].close;

    Bars aggBars = futures[4];
    double aggWeekClose = 0;
    double aggLastClose = 0;
    for (var bar in aggBars.bars) {
      if (bar.time.toUtc().weekday == DateTime.friday) {
        if (aggWeekClose == 0) {
          aggWeekClose = bar.close;
        } else {
          aggLastClose = bar.close;
        }
      }
    }
    var aggDiff = aggLastClose - aggWeekClose;
    this.bondPosition.lastWeekPLPercent = (aggDiff) / aggWeekClose;
    this.bondPosition.currentPrice = aggBars.bars[aggBars.bars.length - 1].close;

    this.status.target = 20000 * 1.09;
    this.status.is30Down = false;

    List<Order> orders = futures[5];
    log('Got orders ${orders.length}');
    this.accountDetails.setOrders(orders);

    PortfolioHistory history = futures[6];
    this.history.baseValue = history.baseValue;
    this.history.equity = history.equity;
    this.history.profitLoss = history.profitLoss;
    this.history.profitLossPercent = history.profitLossPercent;
    this.history.timestamp = history.timestamp;

    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   this.stockPosition.currentPrice = this.stockPosition.currentPrice + 0.10;
    //   this.stockPosition.marketValue = this.stockPosition.quantity * this.stockPosition.currentPrice;
    // });

    status.notify();
    details.notify();

    initWebsocket();
  }

  void initWebsocket() async {
    channel = IOWebSocketChannel.connect('wss://alpaca.socket.polygon.io/stocks');
    channel.stream.listen((message) {
      var data = json.decode(message);
      if (data[0]['status'] == "auth_success") {
        log("Websocket authenticated");
        channel.sink.add('{"action":"subscribe","params":"Q.TQQQ"}');
        channel.sink.add('{"action":"subscribe","params":"Q.AGG"}');
      } else if (data[0]['status'] == "connected") {
        log("Websocket connected");
        channel.sink.add('{"action":"auth","params":"AKYGMS27W5ON3I3046HV"}');
      } else if (data[0]['message'] == "subscribed to: Q.TQQQ" || data[0]['message'] == "subscribed to: Q.AGG") {
        log("Websocket subscribed");
      } else {
        log("Got Quote: $message");
        for (var msg in data) {
          this.setStockPrice(msg['sym'], msg['bp']);
        }
      }
    });
  }

  void setStockPrice(String symbol, double value) {
    if (symbol == "TQQQ") {
      this.stockPosition.currentPrice = value;
    } else if (symbol == "AGG") {
      this.bondPosition.currentPrice = value;
    } else {
      throw new Exception("Usupported stock symbol: $symbol");
    }
  }
}
