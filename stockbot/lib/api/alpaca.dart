import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:stockbot/models/account.dart';
import 'package:stockbot/models/bars.dart';
import 'package:stockbot/models/order.dart';
import 'package:stockbot/models/portfolioHistory.dart';
import 'package:stockbot/models/positionDetails.dart';

class AlpacaApi {
  String _apiKey = "";
  String _secretKey = "";
  
  void setCredentials(String key, String secret) {
    _apiKey = key;
    _secretKey = secret;
  }

  Future<AccountDetails> fetchAccountDetails() async {
    var response = await _makeRequest("/v2/account");
    return AccountDetails.fromJson(json.decode(response.body));
  }

  Future<StockPosition> fetchStockPositionDetails(String symbol) async {
    var response = await _makeRequest("/v2/positions/$symbol");
    if (response.statusCode != 200) {
      var pos = StockPosition();
      pos.symbol = symbol;
      return pos;
    }

    return StockPosition.fromJson(symbol, json.decode(response.body));
  }

  Future<BondPosition> fetchBondPositionDetails(String symbol) async {
    var response = await _makeRequest("/v2/positions/$symbol");
    if (response.statusCode != 200) {
      var pos = BondPosition();
      pos.symbol = symbol;
      return pos;
    }

    return BondPosition.fromJson(symbol, json.decode(response.body));
  }

  Future<PortfolioHistory> fetchPortfolioHistory() async {
    var response = await _makeRequest("/v2/account/portfolio/history?period=3M");
    if (response.statusCode != 200) {
      return null;
    }

    return PortfolioHistory.fromJson(json.decode(response.body));
  }

  Future<Bars> fetchBars(String symbol, {int limit = 14}) async {
    var response = await _makeDataRequest("/v1/bars/1D?limit=$limit&symbols=$symbol");
    if (response.statusCode != 200) {
      return null;
    }

    return Bars.fromJson(symbol, json.decode(response.body));
  }

  Future<List<Order>> fetchOrders() async {
    var response = await _makeRequest('/v2/orders?limit=5&status=all');
    if (response.statusCode != 200) {
      return null;
    }

    List<Order> orders = [];
    log(response.body);
    for(var map in json.decode(response.body)) {
      if (map['status'] == 'new' || map['status'] == 'filled') {
        orders.add(Order.fromJson(map));
      }
    }
    return orders;
  }

  Future<http.Response> _makeRequest(String url) {
    return http.get("https://paper-api.alpaca.markets$url", headers: {
      "APCA-API-KEY-ID": _apiKey,
      "APCA-API-SECRET-KEY": _secretKey
    });
  }

  Future<http.Response> _makeDataRequest(String url) {
    return http.get("https://data.alpaca.markets$url", headers: {
      "APCA-API-KEY-ID": _apiKey,
      "APCA-API-SECRET-KEY": _secretKey
    });
  }
}