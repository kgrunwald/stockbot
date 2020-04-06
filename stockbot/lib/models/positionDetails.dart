import 'package:flutter/foundation.dart';

enum PositionType { STOCK, BOND }

class PositionDetails extends ChangeNotifier {
  String _symbol = "";
  double _averageEntryPrice = 0;
  double _costBasis = 0;
  int _quantity = 0;
  double _currentPrice = 0;
  double _marketValue = 0;
  double _unrealizedPL = 0;
  double _unrealizedPLPercent = 0;
  double _unrealizedIntradayPL = 0;
  double _unrealizedIntradayPLPercent = 0;
  double _lastWeekPLPercent = 0;

  set symbol(String symbol) {
    _symbol = symbol;
    notifyListeners();
  }

  get symbol {
    return _symbol;
  }

  set averageEntryPrice(double price) {
    _averageEntryPrice = price;
    notifyListeners();
  }

  get averageEntryPrice {
    return _averageEntryPrice;
  }

  set costBasis(double basis) {
    _costBasis = basis;
    notifyListeners();
  }

  get costBasis {
    return _costBasis;
  }

  set quantity(int qty) {
    _quantity = qty;
    notifyListeners();
  }

  int get quantity {
    return _quantity;
  }

  set currentPrice(double price) {
    _currentPrice = price;
    notifyListeners();
  }

  get currentPrice {
    return _currentPrice;
  }

  set marketValue(double value) {
    _marketValue = value;
    notifyListeners();
  }

  get marketValue {
    return _marketValue;
  }

  set unrealizedPL(double pl) {
    _unrealizedPL = pl;
    notifyListeners();
  }

  get unrealizedPL {
    return _unrealizedPL;
  }

  set unrealizedPLPercent(double pct) {
    _unrealizedPLPercent = pct;
    notifyListeners();
  }

  get unrealizedPLPercent {
    return _unrealizedPLPercent;
  }

  set unrealizedIntradayPL(double pl) {
    _unrealizedIntradayPL = pl;
    notifyListeners();
  }

  get unrealizedIntradayPL {
    return _unrealizedIntradayPL;
  }

  set unrealizedIntradayPLPercent(double pct) {
    _unrealizedIntradayPLPercent = pct;
    notifyListeners();
  }

  get unrealizedIntradayPLPercent {
    return _unrealizedIntradayPLPercent;
  }

  set lastWeekPLPercent(double pct) {
    _lastWeekPLPercent = pct;
    notifyListeners();
  }

  get lastWeekPLPercent {
    return _lastWeekPLPercent;
  }

  void populateJson(Map<String, dynamic> json) {
    this.symbol = json['symbol'];
    this.averageEntryPrice = double.parse(json['avg_entry_price']);
    this.costBasis = double.parse(json['cost_basis']);
    this.quantity = int.parse(json['qty']);
    this.currentPrice = double.parse(json['current_price']);
    this.marketValue = double.parse(json['market_value']);
    this.unrealizedPL = double.parse(json['unrealized_pl']);
    this.unrealizedPLPercent = double.parse(json['unrealized_plpc']);
    this.unrealizedIntradayPL = double.parse(json['unrealized_intraday_pl']);
    this.unrealizedIntradayPLPercent =
        double.parse(json['unrealized_intraday_plpc']);
  }
}

class StockPosition extends PositionDetails {
  StockPosition() : super();

  factory StockPosition.fromJson(String symbol, Map<String, dynamic> json) {
    var pos = StockPosition();
    pos.populateJson(json);
    pos.symbol = symbol;
    return pos;
  }
}

class BondPosition extends PositionDetails {
  BondPosition() : super();

  factory BondPosition.fromJson(String symbol, Map<String, dynamic> json) {
    var pos = BondPosition();
    pos.populateJson(json);
    pos.symbol = symbol;
    return pos;
  }
}
