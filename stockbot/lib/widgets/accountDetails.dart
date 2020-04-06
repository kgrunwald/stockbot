import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'package:Stockbot/models/account.dart' as acctModel;
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/models/positionDetails.dart';
import 'package:Stockbot/utils/colors.dart';
import 'package:Stockbot/utils/format.dart';
import 'package:Stockbot/widgets/accountVizualization.dart';
import 'package:Stockbot/widgets/detailTable.dart';
import 'package:Stockbot/widgets/growthPercentage.dart';
import 'package:Stockbot/widgets/heroWidget.dart';
import 'package:Stockbot/widgets/sectionHeader.dart';

class Data {
  String key;
  double value;
  double percentage;
  Color color;

  Data(this.key, this.value, this.percentage, this.color);
}

class AccountDetails extends StatelessWidget {
  PortfolioHistory history;
  PositionDetails stockPosition;
  PositionDetails bondPosition;
  double stockPercentage;
  double bondPercentage;
  double cashPercentage;

  acctModel.AccountDetails acctDetails;

  AccountDetails({this.history, this.stockPosition, this.bondPosition, this.acctDetails});

  List<charts.Series<Data, int>> seriesData(BuildContext context) {
    bondPercentage = bondPosition.marketValue / acctDetails.totalEquity;
    stockPercentage = stockPosition.marketValue / acctDetails.totalEquity;
    cashPercentage = acctDetails.cashBalance / acctDetails.totalEquity;

    final data = [
      new Data(bondPosition.symbol, bondPosition.marketValue, bondPercentage, StockbotColors.Accent4),
      new Data(stockPosition.symbol, stockPosition.marketValue, stockPercentage, StockbotColors.Accent1),
      new Data("Cash", acctDetails.cashBalance, cashPercentage, StockbotColors.Accent2)
    ];

    return [
      charts.Series<Data, int>(
          id: "allocation",
          colorFn: (Data d, _) => charts.ColorUtil.fromDartColor(d.color),
          domainFn: (_, int i) => i,
          measureFn: (Data d, _) => d.value,
          data: data)
    ];
  }

  final TextStyle textStyle = TextStyle(fontSize: 14, height: 1.75);

  final TextStyle detailTextStyle = TextStyle(
    fontSize: 14,
    height: 1.75,
    color: Colors.grey.shade200,
    fontWeight: FontWeight.w100,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        HeroWidget(
            title: Format.currency.format(acctDetails.totalEquity),
            subTitle: "Account Balance",
            right: GrowthPercentage(percent: acctDetails.growthPercentage, fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 120,
              width: 120,
              margin: EdgeInsets.only(right: 8),
              child: charts.PieChart(
                seriesData(context),
                animate: false,
                defaultRenderer: charts.ArcRendererConfig(
                  arcWidth: 12,
                ),
              ),
            ),
            Table(
              columnWidths: {
                0: FixedColumnWidth(15),
                1: FixedColumnWidth(40),
                2: FixedColumnWidth(50),
                3: FixedColumnWidth(85),
              },
              children: <TableRow>[
                TableRow(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12),
                    child: Container(
                      color: StockbotColors.Accent1,
                      height: 16,
                      width: 2,
                    ),
                  ),
                  Text(stockPosition.symbol, style: textStyle),
                  Text(Format.percentage.format(stockPercentage), style: detailTextStyle, textAlign: TextAlign.end),
                  Text(Format.currency.format(stockPosition.marketValue),
                      style: detailTextStyle, textAlign: TextAlign.end),
                ]),
                TableRow(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12),
                    child: Container(
                      color: StockbotColors.Accent4,
                      height: 16,
                      width: 2,
                    ),
                  ),
                  Text(bondPosition.symbol, style: textStyle),
                  Text(Format.percentage.format(bondPercentage), style: detailTextStyle, textAlign: TextAlign.end),
                  Text(Format.currency.format(bondPosition.marketValue),
                      style: detailTextStyle, textAlign: TextAlign.end),
                ]),
                TableRow(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12),
                    child: Container(
                      color: StockbotColors.Accent2,
                      height: 16,
                      width: 2,
                    ),
                  ),
                  Text("Cash", style: textStyle),
                  Text(Format.percentage.format(cashPercentage), style: detailTextStyle, textAlign: TextAlign.end),
                  Text(
                    Format.currency.format(acctDetails.cashBalance),
                    style: detailTextStyle,
                    textAlign: TextAlign.end,
                  ),
                ])
              ],
            ),
          ],
        ),
        SectionHeader("Performance"),
        Consumer<acctModel.AccountDetails>(
            builder: (_, details, __) => AccountVizualization(history: history, details: details)),
        SectionHeader("Order History"),
        DetailTable(
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2)
            },
            children: acctDetails.orders
                .map((order) => DetailTable.stockOrderRow(
                    order.symbol, order.side, order.formattedTime, order.quantity, order.price))
                .toList())
      ],
    );
  }
}
