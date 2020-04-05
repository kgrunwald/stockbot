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
      volume: json['v'].toInt()
    );
  }
}

class Bars {
  final List<Bar> bars;

  Bars({this.bars});

  factory Bars.fromJson(String symbol, Map<String, dynamic> json) {
    var symbolBars = json[symbol];
    var bars = List<Bar>();
    if (symbolBars != null) {
      for(var bar in symbolBars) {
        bars.add(Bar.fromJson(bar));
      }
    }
    return Bars(bars: bars);
  }
}