import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/widgets/accountDetails.dart' as acctDetailsWidget;

class AccountDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Consumer<PortfolioHistory>(builder: (_, history, __) {
          return Consumer<PlanStatus>(builder: (_, status, __) {
            return acctDetailsWidget.AccountDetails(
                history: history,
                stockPosition: status.stockPosition,
                bondPosition: status.bondPosition,
                acctDetails: status.accountDetails);
          });
        })
      ],
    );
  }
}
