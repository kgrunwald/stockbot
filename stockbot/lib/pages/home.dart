import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/models/planStatus.dart';
import 'package:Stockbot/widgets/overview.dart';
import 'package:Stockbot/widgets/accountSummary.dart';
import 'package:Stockbot/widgets/planSummary.dart';
import 'package:Stockbot/widgets/vizualization.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Consumer<PlanStatus>(
        builder: (_, status, __) => Column(
          children: <Widget>[
            Overview(status: status),
            Consumer<Bars>(
              builder: (_, bars, __) => Vizualization(
                status: status,
                bars: bars,
                startBalance: 20000,
              )
            ),
            PlanSummary(status: status),
            AccountSummary(details: status.accountDetails)
          ],
        ),
      ),
    ]);
  }
}
