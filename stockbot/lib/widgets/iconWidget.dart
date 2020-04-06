import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;

  IconWidget({@required this.icon, @required this.color, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
          decoration: new BoxDecoration(color: this.color, borderRadius: new BorderRadius.all(Radius.circular(8))),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(this.icon, color: (iconColor != null) ? iconColor : Colors.white, size: 26),
          )),
    );
  }
}
