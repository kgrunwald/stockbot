
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockbot/api/alpaca.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/models/portfolioHistory.dart';
import 'package:stockbot/models/positionDetails.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/widgets/accountDetails.dart' as acctDetailsWidget;

class AccountDetailsPage extends StatefulWidget {
  AccountDetailsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  PortfolioHistory history;

  Future<bool> futureStateLoaded;

  @override
  void initState() {
    super.initState();
    futureStateLoaded = _loadPositions();
  }

  Future<bool> _loadPositions() async {
    var api = AlpacaApi();
    var futures = await Future.wait([
      api.fetchPortfolioHistory()
    ]);
    history = futures[0];
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: futureStateLoaded,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Column(
            children: <Widget>[
              Consumer<PlanStatus>(
                builder: (_, status, __) {
                  return acctDetailsWidget.AccountDetails(history: history, stockPosition: status.stockPosition, bondPosition: status.bondPosition, acctDetails: status.accountDetails);
                }
              )
            ],
          );
        }

        return Center(child: CircularProgressIndicator(),);
      }
    );
  }

}