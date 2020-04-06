import 'package:flutter/material.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/utils/colors.dart';
import 'package:Stockbot/utils/format.dart';
import 'package:Stockbot/widgets/detailTable.dart';
import 'package:Stockbot/widgets/sectionHeader.dart';
import 'package:Stockbot/widgets/stockStatus.dart';

class PlanSummary extends StatelessWidget {
  final PlanStatus status;

  PlanSummary({@required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(children: <Widget>[SectionHeader("9Sig Summary")]),
            Row(
              children: <Widget>[
                Container(
                  width: 195,
                  child: StockStatus(stock: status.stockPosition),
                ),
                Container(width: 180, child: StockStatus(stock: status.bondPosition)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 185,
                  child: DetailTable(
                    children: [
                      DetailTable.textRow("9Sig Target", Format.currency.format(status.target)),
                      DetailTable.textRow(status.differenceFromTarget >= 0 ? "Surplus" : "Shortfall",
                          Format.currency.format(status.differenceFromTarget)),
                      DetailTable.textRow("TQQQ", Format.currency.format(status.stockPosition.marketValue)),
                      DetailTable.textRow("AGG", Format.currency.format(status.bondPosition.marketValue)),
                      DetailTable.textRow("30 Down", status.is30Down ? "Yes" : "No"),
                      DetailTable.textRow("TQQQ Action",
                          "${status.stockAction} ${status.stockAction != "None" ? status.stockActionAmount : ""}"),
                    ],
                  ),
                ),
                Container(
                  width: 185,
                  child: DetailTable(
                    children: [
                      DetailTable.textRow("From Plan", Format.growthPercentage.format(status.percentageFromTarget)),
                      DetailTable.textRow("Target Shares", "${status.targetStockShares}"),
                      DetailTable.textRow("TQQQ Shares", "${status.stockPosition.quantity}"),
                      DetailTable.textRow("AGG Shares", "${status.bondPosition.quantity}"),
                      DetailTable.textRow("AGG to \$0", status.bondSignalTo0 ? "Yes" : "No"),
                      DetailTable.textRow("AGG Action",
                          "${status.bondAction} ${status.bondAction != "None" ? status.bondActionAmount : ""}"),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }
}
