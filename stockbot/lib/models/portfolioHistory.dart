import 'dart:collection';

import 'package:flutter/material.dart';

class PortfolioHistory extends ChangeNotifier {
  List<DateTime> _timestamp = [];
  List<double> _equity = [];
  List<double> _profitLoss = [];
  List<double> _profitLossPercent = [];
  double _baseValue = 0.0;

  PortfolioHistory.init();

  PortfolioHistory({timestamp, equity, profitLoss, profitLossPercent, baseValue}) {
    this.timestamp = timestamp;
    this.equity = equity;
    this.profitLoss = profitLoss;
    this.profitLossPercent = profitLossPercent;
    this.baseValue = baseValue;
  }

  set timestamp(List<DateTime> ts) {
    _timestamp.clear();
    _timestamp.addAll(ts);
    notifyListeners();
  }

  UnmodifiableListView<DateTime> get timestamp => UnmodifiableListView(_timestamp);

  set equity(List<double> eq) {
    _equity.clear();
    _equity.addAll(eq);
    notifyListeners();
  }

  UnmodifiableListView<double> get equity => UnmodifiableListView(_equity);

  set profitLoss(List<double> pl) {
    _profitLoss.clear();
    _profitLoss.addAll(pl);
    notifyListeners();
  }

  UnmodifiableListView<double> get profitLoss => UnmodifiableListView(_profitLoss);

  set profitLossPercent(List<double> plpc) {
    _profitLossPercent.clear();
    _profitLossPercent.addAll(plpc);
    notifyListeners();
  }

  UnmodifiableListView<double> get profitLossPercent => UnmodifiableListView(_profitLossPercent);

  set baseValue(double val) {
    _baseValue = val;
    notifyListeners();
  }

  double get baseValue => _baseValue;

  static List<double> _toDouble(List<dynamic> l) {
    var doubles = List<double>();
    for (var d in l) {
      doubles.add(d.toDouble());
    }

    return doubles;
  }

  factory PortfolioHistory.fromJson(Map<String, dynamic> json) {
    var dts = List<DateTime>();
    for (var ts in json['timestamp']) {
      dts.add(DateTime.fromMillisecondsSinceEpoch(ts * 1000));
    }

    return PortfolioHistory(
        timestamp: dts,
        equity: _toDouble(json['equity']),
        profitLoss: _toDouble(json['profit_loss']),
        profitLossPercent: _toDouble(json['profit_loss_pct']),
        baseValue: json['base_value'].toDouble());
  }
}
