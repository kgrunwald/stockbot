import 'package:flutter/material.dart';
import 'package:Stockbot/utils/format.dart';

class GrowthPercentage extends StatelessWidget {
  final double percent;
  final double fontSize;
  final FontWeight fontWeight;

  GrowthPercentage({this.percent, this.fontSize, this.fontWeight = FontWeight.normal});

  Color getTextColor(BuildContext context) {
    if (percent < 0) {
      return Theme.of(context).errorColor;
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      Format.growthPercentage.format(this.percent),
      style: TextStyle(color: getTextColor(context), fontSize: this.fontSize, fontWeight: this.fontWeight),
    );
  }
}
