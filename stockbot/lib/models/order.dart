import 'package:intl/intl.dart';

class Order {
  String id;
  DateTime submittedAt;
  String side;
  String status;
  String symbol;
  int quantity;
  double averagePrice;

  Order({this.id, this.submittedAt, this.side, this.status, this.symbol, this.quantity, this.averagePrice});

  double get price => quantity * averagePrice;

  String get formattedTime => DateFormat('y/MM/dd').format(submittedAt);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        submittedAt: DateTime.parse(json['submitted_at']),
        side: json['side'].toString().toUpperCase(),
        status: json['status'],
        symbol: json['symbol'],
        quantity: int.parse(json['qty']),
        averagePrice: double.parse(json['filled_avg_price']));
  }
}
