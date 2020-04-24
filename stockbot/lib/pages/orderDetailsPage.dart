import 'package:Stockbot/locator.dart';
import 'package:Stockbot/models/order.dart';
import 'package:Stockbot/services/navigatorService.dart';
import 'package:Stockbot/utils/format.dart';
import 'package:Stockbot/widgets/detailTable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Stockbot/utils/stringExtension.dart';

class OrderDetailsPage extends StatelessWidget {
  final NavigationService navigationService = locator.get<NavigationService>();

  @override
  Widget build(BuildContext context) {
    final Order order = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(onTap: navigationService.pop,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: 
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).accentColor,
                    ),
                  ],
                ),
              )
            ),
            Text("Order Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(order.symbol),
            ),
            DetailTable(
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                DetailTable.textRow("Order Status", '${order.status.capitalize()}'),
                DetailTable.textRow("Order Side", '${order.side.capitalize()}'),
                DetailTable.textRow("Order Type", "${order.type.capitalize()}"),
                DetailTable.textRow("Submitted", DateFormat.yMMMd().add_jm().format(order.submittedAt)),
                DetailTable.textRow("Submitted Quantity", "${order.quantity}"),
                DetailTable.textRow("Submitted Price", Format.currency.format(order.limitPrice)),
                DetailTable.textRow("Filled", DateFormat.yMMMd().add_jm().format(order.filledAt)),
                DetailTable.textRow("Filled Quantity", "${order.filledQuantity}"),
                DetailTable.textRow("Filled Price", Format.currency.format(order.averagePrice)),
                DetailTable.textRow("Total Price", Format.currency.format(order.averagePrice * order.filledQuantity)),
              ]
            )
          ],
        ),
      ),
    );
  }
}