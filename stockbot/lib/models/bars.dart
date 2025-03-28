import 'dart:collection';

import 'package:flutter/material.dart';

class Bar {
  final DateTime time;
  final double open;
  final double close;
  final double high;
  final double low;
  final int volume;

  Bar({this.time, this.open, this.close, this.high, this.low, this.volume});

  factory Bar.fromJson(Map<String, dynamic> json) {
    return Bar(
        time: DateTime.fromMillisecondsSinceEpoch(json['t'] * 1000),
        open: json['o'].toDouble(),
        close: json['c'].toDouble(),
        high: json['h'].toDouble(),
        low: json['l'].toDouble(),
        volume: json['v'].toInt());
  }
}

class Bars extends ChangeNotifier {
  final List<Bar> _bars = [];

  Bars({List<Bar> bars}) {
    this.bars = bars;
  }

  set bars(List<Bar> b) {
    _bars.clear();
    if (b != null) {
      _bars.addAll(b);
    }

    notifyListeners();
  }

  UnmodifiableListView<Bar> get bars => UnmodifiableListView(_bars);

  factory Bars.fromJson(String symbol, Map<String, dynamic> json) {
    var symbolBars = json[symbol];
    var bars = List<Bar>();
    if (symbolBars != null) {
      for (var bar in symbolBars) {
        bars.add(Bar.fromJson(bar));
      }
    }
    return Bars(bars: bars);
  }
}
