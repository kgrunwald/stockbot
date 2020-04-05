
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/utils/format.dart';
import 'package:stockbot/widgets/growthPercentage.dart';
import 'package:stockbot/widgets/iconWidget.dart';
import 'package:stockbot/widgets/sectionHeader.dart';

class AccountSummary extends StatelessWidget {
  final AccountDetails details;

  AccountSummary({this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SectionHeader("Portfolio Summary"),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconWidget(
                    icon: Icons.account_balance,
                    color: Theme.of(context).accentColor,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Format.currency.format(details.totalEquity),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Total Equity",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              GrowthPercentage(percent: details.growthPercentage, fontSize: 16, fontWeight: FontWeight.bold)
            ],
          ),
        ),
      ],
    );
  }
}