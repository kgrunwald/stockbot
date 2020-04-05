import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  
  SectionHeader(this.text, {this.fontSize = 18, this.fontWeight = FontWeight.bold});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(fontSize: this.fontSize, fontWeight: this.fontWeight)
          ),
        ],
      ),
    );
  }
}