import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color subTitleColor;
  final Widget right;

  HeroWidget({this.title, this.subTitle, this.subTitleColor = Colors.white, this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.title,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    this.subTitle,
                    style: TextStyle(fontSize: 16, height: 1.5, color: subTitleColor),
                  ),
                ],
              ),
            ],
          ),
          this.right != null ? this.right : Text("")
        ],
      ),
    );
  }
}
