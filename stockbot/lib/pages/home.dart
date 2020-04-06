import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockbot/api/alpaca.dart';
import 'package:stockbot/locator.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/models/bars.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/widgets/overview.dart';
import 'package:stockbot/widgets/accountSummary.dart';
import 'package:stockbot/widgets/planSummary.dart';
import 'package:stockbot/widgets/vizualization.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Bars> futureBars;
  WebSocketChannel channel;

  @override
  void initState() {
    super.initState();    
    futureBars = _loadBars();
  }

  Future<Bars> _loadBars() async {
    var api = locator.get<AlpacaApi>();
    return await api.fetchBars("TQQQ");
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
        Consumer<PlanStatus>(
          builder: (_, status, __) => Overview(status: status),
        ),
        FutureBuilder<Bars>(
          future: futureBars,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return Consumer<PlanStatus>(
                builder: (_, status, __) => Vizualization(bars: snapshot.data, quantity: status.stockPosition.quantity, startBalance: 20000, targetBalance: status.target)
              );
            } else if(snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Container();
          }
        ),
        Consumer<PlanStatus>(
          builder: (_, status, __) => PlanSummary(status: status)
        ),
        Consumer<AccountDetails>(
          builder: (_, details, __) => AccountSummary(details: details)
        )
      ]
    );
  }
}
