import 'package:intl/intl.dart';
import 'package:Stockbot/utils/stringExtension.dart';

class Order {
  String id;
  DateTime submittedAt;
  DateTime filledAt;
  String side;
  String type;
  String status;
  String symbol;
  int quantity;
  int filledQuantity;
  double averagePrice;
  double limitPrice;

  Order({this.id, this.submittedAt, this.filledAt, this.side, this.type, this.status, this.symbol, this.quantity, this.filledQuantity, this.limitPrice, this.averagePrice});

  double get price => quantity * averagePrice;

  String get formattedTime => DateFormat('y/MM/dd').format(submittedAt);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        submittedAt: DateTime.parse(json['submitted_at']),
        filledAt: DateTime.parse(json['filled_at']),
        side: json['side'].toString().capitalize(),
        status: json['status'],
        type: json['type'],
        symbol: json['symbol'],
        quantity: int.parse(json['qty']),
        filledQuantity: int.parse(json['filled_qty']),
        limitPrice: json['limit_price'] != null ? double.parse(json['limit_price']) : 0.0,
        averagePrice: double.parse(json['filled_avg_price']));
  }
}
