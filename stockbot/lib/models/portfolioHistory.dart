class PortfolioHistory {
  final List<DateTime> timestamp;
  final List<double> equity;
  final List<double> profitLoss;
  final List<double> profitLossPercent;
  final double baseValue;

  PortfolioHistory({
    this.timestamp, 
    this.equity,
    this.profitLoss,
    this.profitLossPercent,
    this.baseValue
  });

  static List<double> _toDouble(List<dynamic> l) {
    var doubles = List<double>();
    for(var d in l) {
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
      baseValue: json['base_value'].toDouble()
    );
  }
}