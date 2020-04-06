import 'package:flutter/material.dart';
import 'package:Stockbot/utils/colors.dart';
import 'package:Stockbot/utils/format.dart';

class DetailTable extends StatelessWidget {
  final List<TableRow> children;
  final Map<int, TableColumnWidth> columnWidths;

  DetailTable({this.children, this.columnWidths});

  static final BorderSide _border = BorderSide(color: Colors.grey, width: 1);
  static final EdgeInsets _padding = const EdgeInsets.only(bottom: 10, top: 10);

  static TableRow textRow(String label, String value) {
    return TableRow(children: [
      Padding(
          padding: _padding,
          child: Text(label, style: TextStyle(color: Colors.grey.shade400))),
      Padding(
        padding: _padding,
        child: Text(value,
            textAlign: TextAlign.end, style: TextStyle(fontSize: 16)),
      )
    ]);
  }

  static TableRow stockOrderRow(
      String stock, String side, String date, int quantity, double price) {
    return _orderRow(
        stock, StockbotColors.Accent1, side, date, quantity, price);
  }

  static TableRow bondOrderRow(
      String stock, String side, String date, int quantity, double price) {
    return _orderRow(
        stock, StockbotColors.Accent4, side, date, quantity, price);
  }

  static TableRow _orderRow(String stock, Color color, String side, String date,
      int quantity, double price) {
    return TableRow(children: [
      Padding(
          padding: _padding,
          child: Text(stock,
              style: TextStyle(fontWeight: FontWeight.bold, color: color))),
      Padding(
        padding: _padding,
        child: Text(date,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
      ),
      Padding(
        padding: _padding,
        child: Text(side,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
      ),
      Padding(
        padding: _padding,
        child: Text("$quantity",
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
      ),
      Padding(
        padding: _padding,
        child: Text(Format.currency.format(price),
            textAlign: TextAlign.end, style: TextStyle(fontSize: 16)),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: columnWidths,
      border: TableBorder(bottom: _border, horizontalInside: _border),
      children: this.children,
    );
  }
}
