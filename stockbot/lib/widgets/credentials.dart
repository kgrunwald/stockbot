import 'package:flutter/material.dart';
import 'package:stockbot/locator.dart';
import 'package:stockbot/services/stockbotService.dart';
import 'package:stockbot/services/storageService.dart';

class Credentials extends StatelessWidget {
  final StockbotService stockbot = locator.get<StockbotService>();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Alpaca API Key",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              TextFormField(
                autocorrect: false,
                autofocus: false,
                enabled: true,
                initialValue: stockbot.apiKey,
                onChanged: (key) => stockbot.setApiKey(key),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Alpaca API Secret Key",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        TextFormField(
          autocorrect: false,
          autofocus: false,
          enabled: true,
          initialValue: stockbot.apiSecretKey,
          onChanged: (key) => stockbot.setApiSecretKey(key),
        )
      ],
    );
  }
}