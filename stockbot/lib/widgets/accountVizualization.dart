import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Stockbot/models/account.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/utils/colors.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BalancePoint {
  final DateTime date;
  final double balance;

  BalancePoint(this.date, this.balance);
}

class AccountVizualization extends StatelessWidget {
  final PortfolioHistory history;
  final AccountDetails details;

  AccountVizualization({@required this.history, @required this.details});

  List<charts.Series<BalancePoint, DateTime>> data() {
    var data = List<BalancePoint>();
    for (int i = 0; i < this.history.timestamp.length; i++) {
      var ts = this.history.timestamp[i];
      var equity = this.history.equity[i];
      data.add(BalancePoint(ts, equity));
    }

    data.add(BalancePoint(DateTime.now(), details.totalEquity));

    return [
      new charts.Series<BalancePoint, DateTime>(
        id: 'Balance',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(StockbotColors.Secondary),
        domainFn: (BalancePoint point, _) => point.date,
        measureFn: (BalancePoint point, _) => point.balance,
        data: data,
      )
    ];
  }

  final simpleCurrencyFormatter =
      new charts.BasicNumericTickFormatterSpec.fromNumberFormat(new NumberFormat.compactSimpleCurrency());

  @override
  Widget build(BuildContext context) {
    if (details == null || history == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        height: 200,
        width: 1700,
        child: Center(
            child: charts.TimeSeriesChart(data(),
                animate: false,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
                defaultRenderer: charts.LineRendererConfig(includeArea: true),
                domainAxis: charts.DateTimeAxisSpec(
                    renderSpec:
                        charts.SmallTickRendererSpec(labelStyle: charts.TextStyleSpec(color: charts.Color.white))),
                primaryMeasureAxis: charts.NumericAxisSpec(
                    tickFormatterSpec: simpleCurrencyFormatter,
                    renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(color: charts.Color.white),
                        lineStyle: charts.LineStyleSpec(dashPattern: [1, 0, 1]))))),
      ),
    );
  }
}
