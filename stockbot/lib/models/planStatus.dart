import 'dart:math';

import "dart:developer" as dev;
import 'package:flutter/material.dart';
import 'package:stockbot/models/account.dart';
import 'package:stockbot/models/positionDetails.dart';

class PlanStatus extends ChangeNotifier {
  StockPosition _stockPosition;
  BondPosition _bondPosition;
  AccountDetails _accountDetails;
  double _target = 1.0;
  bool _is30Down = true;

  PlanStatus(AccountDetails details, StockPosition stock, BondPosition bond) {
    _accountDetails = details;
    _stockPosition = stock;
    _bondPosition = bond;

    _accountDetails.addListener(this.notifyListeners);
    _stockPosition.addListener(this.notifyListeners);
    _bondPosition.addListener(this.notifyListeners);
  }

  StockPosition get stockPosition {
    return _stockPosition;
  }

  BondPosition get bondPosition {
    return _bondPosition;
  }

  AccountDetails get accountDetails {
    return _accountDetails;
  }

  set target(double tgt) {
    _target = tgt;
    notifyListeners();
  }

  set is30Down(bool down) {
    _is30Down = down;
    notifyListeners();
  }

  bool get is30Down {
    return _is30Down;
  }

  double get target {
    return _target;
  }

  double get percentageFromTarget {
    return ((stockPosition.marketValue - target) / target);
  }

  double get differenceFromTarget {
    return stockPosition.marketValue - target;
  }

  int get targetStockShares {
    return (target / stockPosition.currentPrice).floor().toInt();
  }

  String get stockAction {
    if (targetStockShares > stockPosition.quantity) {
      return 'Buy';
    } else if ((targetStockShares < stockPosition.quantity) && !is30Down) {
      return 'Sell';
    }

    return 'None';
  }

  int get stockActionAmount {
    var numShares = (targetStockShares - stockPosition.quantity).abs();
    if (targetStockShares > stockPosition.quantity) {
      // We are buying, make sure we have enough bond / cash to cover it
      var amount = numShares * stockPosition.currentPrice;
      if (amount > (bondPosition.marketValue + accountDetails.cashBalance)) {
        return ((bondPosition.marketValue + accountDetails.cashBalance) / stockPosition.currentPrice).floor().toInt();
      }
    }

    // We are selling, can't sell more than we have.
    return min(numShares, stockPosition.quantity);
  }

  String get bondAction {
    if (targetStockShares > stockPosition.quantity) {
      return 'Sell';
    } else if ((targetStockShares < stockPosition.quantity) && !is30Down) {
      return 'Buy';
    }

    return 'None';
  }

  int get bondActionAmount {
    var rawNumShares = (differenceFromTarget / bondPosition.currentPrice).abs();
    if (differenceFromTarget > 0) {
      // stock surplus. Buy the difference.
      return rawNumShares.floor().toInt();
    }

    // stock shortfall. Sell the difference.
    return min(rawNumShares.ceil().toInt(), bondPosition.quantity);
  }

  bool get bondSignalTo0 {
    return bondActionAmount - bondPosition.quantity == 0;
  }

  void notify() {
    this.notifyListeners();
  }
}