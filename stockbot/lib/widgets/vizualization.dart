import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockbot/models/bars.dart';
import 'package:stockbot/utils/colors.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BalancePoint {
  final DateTime date;
  final double balance;
  

  BalancePoint(this.date, this.balance);
}

class Vizualization extends StatelessWidget {
  Bars bars;
  int quantity;
  final double startBalance;
  final double targetBalance;

  Vizualization({this.bars, this.quantity, this.startBalance, this.targetBalance});

   List<charts.Series<BalancePoint, DateTime>> data() {
    var data = List<BalancePoint>();
    for(var bar in this.bars.bars) {
      data.add(BalancePoint(bar.time, bar.close * this.quantity));
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
        new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            new NumberFormat.compactSimpleCurrency());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        height: 200,
        width: 600,
        child: Center(
          child: charts.TimeSeriesChart(
            data(),
            animate: false,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            defaultRenderer: charts.LineRendererConfig(includeArea: true),
            domainAxis: charts.DateTimeAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(color: charts.Color.white)
              )
            ),
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickFormatterSpec: simpleCurrencyFormatter,
              tickProviderSpec: charts.StaticNumericTickProviderSpec([charts.TickSpec(this.startBalance), charts.TickSpec(this.targetBalance)]),
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(color: charts.Color.white),
                lineStyle: charts.LineStyleSpec(dashPattern: [1, 0, 1])
              )
            )
          )
        ),
      ),
    );
  }

}