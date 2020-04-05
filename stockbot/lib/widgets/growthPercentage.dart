import 'package:flutter/material.dart';
import 'package:stockbot/utils/format.dart';

class GrowthPercentage extends StatelessWidget {
  final double percent;
  final double fontSize;
  FontWeight fontWeight = FontWeight.normal;

  GrowthPercentage({this.percent, this.fontSize, this.fontWeight});

  Color getTextColor(BuildContext context) {
    if (percent < 0) {
      return Theme.of(context).errorColor;
    } 
    return Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      Format.growthPercentage.format(this.percent),
      style: TextStyle(
        color: getTextColor(context),
        fontSize: this.fontSize,
        fontWeight: this.fontWeight
      ),
    );
  }
}