import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:Stockbot/models/order.dart';
import 'package:Stockbot/models/positionDetails.dart';

class AccountDetails extends ChangeNotifier {
  double _cashBalance;
  StockPosition _stock;
  BondPosition _bond;
  final List<Order> _orders = [];

  AccountDetails({cashBalance, stockPosition, bondPosition}) {
    this.cashBalance = cashBalance;
    this._stock = stockPosition;
    this._bond = bondPosition;

    if (_stock != null) {
      this._stock.addListener(this.notifyListeners);
    }

    if (_bond != null) {
      this._bond.addListener(this.notifyListeners);
    }
  }

  double get growthPercentage => (totalEquity - totalBasis - cashBalance) / (totalBasis + cashBalance);

  set cashBalance(double balance) {
    _cashBalance = balance;
    notifyListeners();
  }

  double get cashBalance => _cashBalance;

  double get totalEquity =>
      this._cashBalance +
      this._stock.currentPrice * this._stock.quantity +
      this._bond.currentPrice * this._bond.quantity;

  double get totalBasis => this._stock.costBasis + this._bond.costBasis;

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void setOrders(List<Order> orders) {
    _orders.addAll(orders);
    notifyListeners();
  }

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(cashBalance: double.parse(json['cash']));
  }

  void notify() {
    this.notifyListeners();
  }
}
