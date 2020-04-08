import 'package:Stockbot/models/account.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/utils/colors.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BalancePoint {
  final DateTime date;
  final double balance;

  BalancePoint(this.date, this.balance);
}

class Vizualization extends StatelessWidget {
  Bars bars;
  PlanStatus status;
  int quantity;
  final double startBalance;

  Vizualization({this.bars, this.status, this.startBalance});

  List<charts.Series<BalancePoint, DateTime>> data() {
    var data = List<BalancePoint>();
    var orders = status.accountDetails.orders;
    for (var bar in this.bars.bars) {
      int quantity = 0;
      for (var order in orders) {
        if (order.submittedAt.isBefore(bar.time)) {
          quantity += order.quantity;
        }
      }
      data.add(BalancePoint(bar.time, bar.close * quantity));
    }

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        height: 200,
        width: 600,
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
                    tickProviderSpec: charts.StaticNumericTickProviderSpec(
                        [charts.TickSpec(this.startBalance), charts.TickSpec(status.target)]),
                    renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(color: charts.Color.white),
                        lineStyle: charts.LineStyleSpec(dashPattern: [1, 0, 1]))))),
      ),
    );
  }
}
