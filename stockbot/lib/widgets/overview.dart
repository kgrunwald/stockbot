import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockbot/models/planStatus.dart';
import 'package:stockbot/utils/format.dart';
import 'package:stockbot/widgets/heroWidget.dart';

class Overview extends StatelessWidget {
  final PlanStatus status;
  Overview({Key key, @required this.status}) : super(key: key);

  get _targetDiff {
    if (status.percentageFromTarget < 0) {
      return "(${Format.currency.format(status.differenceFromTarget.abs())})";
    }
    return "${Format.currency.format(status.differenceFromTarget)}";
  }

  Color _getPerformanceTextColor(BuildContext context) {
    if (status.percentageFromTarget < 0) {
      return Theme.of(context).errorColor;
    } 
    return Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return HeroWidget(
      title: Format.currency.format(status.stockPosition.marketValue),
      subTitle: "${Format.percentage.format(status.percentageFromTarget)}  $_targetDiff",
      subTitleColor: _getPerformanceTextColor(context),
    );
  }
}