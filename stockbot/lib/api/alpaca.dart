import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:Stockbot/models/account.dart';
import 'package:Stockbot/models/bars.dart';
import 'package:Stockbot/models/order.dart';
import 'package:Stockbot/models/portfolioHistory.dart';
import 'package:Stockbot/models/positionDetails.dart';
import 'package:intl/intl.dart';

class AlpacaApi {
  String _apiKey = "";
  String _secretKey = "";
  String _baseUrl = "";

  void setCredentials(String key, String secret, String url) {
    _apiKey = key;
    _secretKey = secret;
    _baseUrl = url;
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

  Future<List<PositionDetails>> fetchPositions() async {
    var response = await _makeRequest("/v2/positions");
    if (response.statusCode != 200) {
      return [];
    }

   List<dynamic> res =  json.decode(response.body);
   List<PositionDetails> retVal = [];
   for(var map in res) {
     var details = PositionDetails();
     details.populateJson(map);
     retVal.add(details);
   }

   return retVal;
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

  Future<Bars> fetchBars(String symbol, {int limit, DateTime start, DateTime end}) async {
    Map<String, String> query = {};
    query['symbols'] = symbol;

    if (limit != null) {
      query["limit"] = "$limit";
    }

    if (start != null) {
      query['start'] = start.toIso8601String();
    }

    if (end != null) {
      query['end'] = end.toIso8601String();
    }

    var url = Uri(path: "/v1/bars/1D", queryParameters: query);
    log(url.toString());
    var response = await _makeDataRequest(url.toString());
    if (response.statusCode != 200) {
      log(response.body);
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
    for (var map in json.decode(response.body)) {
      if (map['status'] == 'new' || map['status'] == 'filled') {
        orders.add(Order.fromJson(map));
      }
    }
    return orders;
  }

  Future<http.Response> _makeRequest(String url) {
    return http.get("$_baseUrl$url",
        headers: {"APCA-API-KEY-ID": _apiKey, "APCA-API-SECRET-KEY": _secretKey});
  }

  Future<http.Response> _makeDataRequest(String url) {
    return http.get("https://data.alpaca.markets$url",
        headers: {"APCA-API-KEY-ID": _apiKey, "APCA-API-SECRET-KEY": _secretKey});
  }
}
