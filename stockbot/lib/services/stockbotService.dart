import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:stockbot/api/alpaca.dart';
import 'package:stockbot/locator.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/models/bars.dart';
import 'package:stockbot/models/order.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/models/positionDetails.dart';
import 'package:web_socket_channel/io.dart';

class StockbotService {
  AccountDetails accountDetails;
  StockPosition stockPosition;
  BondPosition bondPosition;
  PlanStatus status;
  IOWebSocketChannel channel;

  StockbotService() {
    accountDetails = locator.get<AccountDetails>();
    stockPosition = locator.get<StockPosition>();
    bondPosition = locator.get<BondPosition>();
    status = locator.get<PlanStatus>();
  }

  Future<void> start() async {
    var api = AlpacaApi();
    var futures = await Future.wait([
      api.fetchAccountDetails(),
      api.fetchStockPositionDetails("TQQQ"),
      api.fetchBondPositionDetails("AGG"),
      api.fetchBars("TQQQ", limit: 10),
      api.fetchBars("AGG", limit: 10),
      api.fetchOrders()
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
    double tqqWeekClose = 0;
    double tqqLastClose = 0;
    for (var bar in tqqBars.bars) {
      if (bar.time.toUtc().weekday == DateTime.friday) {
        if (tqqWeekClose == 0) {
          tqqWeekClose = bar.close;
        } else {
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

    Timer.periodic(Duration(seconds: 1), (timer) {
      this.stockPosition.currentPrice = this.stockPosition.currentPrice + 0.10;
      this.stockPosition.marketValue = this.stockPosition.quantity * this.stockPosition.currentPrice;
    });

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
        for(var msg in data) {
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