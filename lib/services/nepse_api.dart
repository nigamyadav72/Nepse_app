import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_summary.dart';
import '../models/stock.dart';
import '../models/nepse_index.dart';
import '../models/company.dart';

class NepseApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const Duration timeout = Duration(seconds: 15);

  static final NepseApiService _instance = NepseApiService._internal();
  factory NepseApiService() => _instance;
  NepseApiService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<T> _get<T>(String endpoint, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return parser(data);
    } else {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }
  }

  Future<MarketSummary> getMarketSummary() async {
    return _get('/Summary', (data) {
      if (data is Map<String, dynamic>) {
        return MarketSummary.fromJson(data);
      }
      throw Exception('Unexpected summary format');
    });
  }

  Future<List<StockItem>> getLiveMarket() async {
    return _get('/LiveMarket', (data) {
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      return list.map((e) => StockItem.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<List<StockItem>> getTopGainers() async {
    return _get('/TopGainers', (data) {
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      return list.map((e) => StockItem.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<List<StockItem>> getTopLosers() async {
    return _get('/TopLosers', (data) {
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      return list.map((e) => StockItem.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<List<NepseIndex>> getNepseIndex() async {
    return _get('/NepseIndex', (data) {
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List;
      } else if (data is Map) {
        // Single index returned
        return [NepseIndex.fromJson(data as Map<String, dynamic>)];
      } else {
        list = [];
      }
      return list.map((e) => NepseIndex.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<List<Company>> getCompanyList() async {
    return _get('/CompanyList', (data) {
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      return list.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<CompanyDetail> getCompanyDetails(String symbol) async {
    return _get('/CompanyDetails?symbol=$symbol', (data) {
      if (data is Map<String, dynamic>) {
        return CompanyDetail.fromJson(data);
      }
      throw Exception('Unexpected company detail format');
    });
  }

  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await _client.get(uri, headers: _headers).timeout(timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
