import 'package:flutter/material.dart';
import 'package:stockbot/models/positionDetails.dart';
import 'package:stockbot/utils/format.dart';
import 'package:stockbot/widgets/iconWidget.dart';

class StockStatus extends StatelessWidget {
  final PositionDetails stock;

  StockStatus({this.stock});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconWidget(
          icon: stock.lastWeekPLPercent >= 0 ? Icons.trending_up : Icons.trending_down,
          color: stock.lastWeekPLPercent >= 0 ? Theme.of(context).accentColor : Theme.of(context).errorColor,
        ),
        Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${stock.symbol}  ${Format.currency.format(stock.currentPrice)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "Last week: ${Format.growthPercentage.format(stock.lastWeekPLPercent)}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}